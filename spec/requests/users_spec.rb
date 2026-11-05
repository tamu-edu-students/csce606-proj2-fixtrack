require "rails_helper"

RSpec.describe "Users", type: :request do
  let!(:company) do
    Company.create!(name: "Wayne Enterprises")
  end

  let(:manager) do
    User.create!(
      name: "Bruce Wayne",
      email: "bruce@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "manager",
      company: company
    )
  end

  before do
    sign_in manager
  end

  describe "GET /users/new" do
    it "allows the manager to access create user page" do
        get new_user_path
        expect(response).to have_http_status(:success)
    end

    it "displays the user creation form" do
        get new_user_path
        expect(response.body).to include("Create User")
        expect(response.body).to include("Name")
        expect(response.body).to include("Email")
        expect(response.body).to include("Password")
        expect(response.body).to include("Password confirmation")
        expect(response.body).to include("User Type")
    end
  end

  describe "POST /users" do
    it "allows a manager to create a technician" do
      expect {
        post users_path, params: {
          user: {
            name: "Clark Kent",
            email: "clark@example.com",
            password: "password123",
            password_confirmation: "password123",
            role: "technician"
          }
        }
      }.to change(User, :count).by(1)

      technician = User.find_by(email: "clark@example.com")

      expect(technician.role).to eq("technician")
      expect(technician.company).to eq(company)
    end
  end
end