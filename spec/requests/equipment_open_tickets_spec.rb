require "rails_helper"

RSpec.describe "Equipment open tickets", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { User.create!(name: "Reporter", email: "equipment-tickets@example.test", password: "Equipment-test-123!", role: "reporter") }
  let(:equipment) { Equipment.create!(name: "Oscilloscope", asset_identifier: "LAB-019", location: "Lab A", status: "Available") }

  def ticket_for(item, title:, status: "open")
    MaintenanceTicket.create!(equipment: item, reporter: user, title: title,
      description: "Equipment needs attention", priority: "high", status: status)
  end

  %w[manager technician reporter].each do |role|
    it "lets an authenticated #{role} view the selected equipment's open tickets" do
      user.update!(role: role)
      ticket_for(equipment, title: "Display flickers")
      sign_in user

      get equipment_path(equipment)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Display flickers", "High", "Open")
    end
  end

  it "includes every current outstanding status and excludes resolved tickets and other equipment" do
    %w[open assigned in_progress].each { |status| ticket_for(equipment, title: "Problem #{status}", status: status) }
    ticket_for(equipment, title: "Completed repair", status: "resolved")
    other = Equipment.create!(name: "Printer", asset_identifier: "OTHER-019", location: "Office", status: "Available")
    ticket_for(other, title: "Unrelated printer problem")
    sign_in user

    get equipment_path(equipment)

    expect(response.body).to include("Problem open", "Problem assigned", "Problem in_progress", "In progress")
    expect(response.body).not_to include("Completed repair", "Unrelated printer problem")
  end

  it "shows a clear empty state with a reporting link" do
    sign_in user
    get equipment_path(equipment)

    expect(response.body).to include("No open tickets for this equipment.")
    expect(response.body).to include(new_maintenance_ticket_path(equipment_id: equipment.id))
  end

  it "allows an urgent report even when an open ticket already exists" do
    ticket_for(equipment, title: "Existing problem")
    sign_in user

    get new_maintenance_ticket_path(equipment_id: equipment.id)

    expect(response).to have_http_status(:ok)
    expect(response.body).to match(/selected="selected" value="#{equipment.id}"/)
    expect do
      post maintenance_tickets_path, params: { maintenance_ticket: {
        equipment_id: equipment.id, title: "Urgent smoke issue", description: "Smoke visible", priority: "high"
      } }
    end.to change(MaintenanceTicket, :count).by(1)
    expect(MaintenanceTicket.last).to have_attributes(equipment_id: equipment.id, reporter_id: user.id, priority: "high")
  end

  it "redirects anonymous visitors without exposing tickets" do
    ticket_for(equipment, title: "Protected problem")
    get equipment_path(equipment)

    expect(response).to redirect_to(new_user_session_path)
    expect(response.body).not_to include("Protected problem")
  end

  it "returns not found for missing equipment" do
    sign_in user
    get equipment_path(id: 0)

    expect(response).to have_http_status(:not_found)
    expect(response.body).to include("Equipment not found.")
  end
end
