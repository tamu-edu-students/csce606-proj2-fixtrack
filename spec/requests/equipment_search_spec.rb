require "rails_helper"

RSpec.describe "Equipment search", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:company) { Company.create!(name: "Search test company") }
  let(:user) { User.create!(name: "Search user", email: "equipment-search@example.test", password: "Equipment-test-123!", role: "reporter", company: company) }
  let!(:equipment) { Equipment.create!(name: "Oscilloscope", asset_identifier: "LAB-015", location: "Lab A", status: "Available") }
  let!(:other) { Equipment.create!(name: "Printer", asset_identifier: "OFFICE-002", location: "Office", status: "Available") }

  %w[manager technician reporter].each do |role|
    it "allows an authenticated #{role} to search and select matching equipment" do
      user.update!(role: role)
      sign_in user
      before_data = Equipment.order(:id).map(&:attributes)

      get equipment_index_path, params: { q: "  oScIl  " }

      expect(response).to have_http_status(:ok)
      html = Nokogiri::HTML(response.body)
      expect(html.css("tbody tr").length).to eq(1)
      expect(html.at_css("tbody tr").text).to include("Oscilloscope", "LAB-015", "Lab A", "Available")
      expect(html.at_css("tbody a")["href"]).to eq(equipment_path(equipment))
      expect(html.at_css("input[name='q']")["value"]).to eq("oScIl")
      expect(response.body).not_to include("OFFICE-002")
      expect(Equipment.order(:id).map(&:attributes)).to eq(before_data)
    end
  end

  it "searches by asset identifier" do
    sign_in user
    get equipment_index_path, params: { q: "office-0" }

    expect(response.body).to include("OFFICE-002")
    expect(response.body).not_to include("LAB-015")
  end

  it "displays an explicit no-match message and preserves the query" do
    sign_in user
    get equipment_index_path, params: { q: "missing equipment" }

    expect(response.body).to include("No equipment matches your search.")
    expect(Nokogiri::HTML(response.body).at_css("input[name='q']")["value"]).to eq("missing equipment")
  end

  it "shows the equipment list for a whitespace-only query" do
    sign_in user
    get equipment_index_path, params: { q: "   " }

    expect(response.body).to include("LAB-015", "OFFICE-002")
    expect(response.body).not_to include("No equipment matches your search.")
  end

  it "redirects anonymous searches to login without exposing results" do
    get equipment_index_path, params: { q: "Oscilloscope" }

    expect(response).to redirect_to(new_user_session_path)
    expect(response.body).not_to include("LAB-015", "Lab A")
  end

  it "escapes search text when redisplaying the query" do
    sign_in user
    get equipment_index_path, params: { q: '<script>alert("x")</script>' }

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('<script>alert("x")</script>')
  end
end
