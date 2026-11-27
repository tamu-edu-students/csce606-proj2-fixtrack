
require "rails_helper"

RSpec.describe "View submitted tickets", type: :request do
  let!(:company) do
    Company.create!(name: "Submitted Tickets Test Company")
  end

  let!(:reporter) do
    User.create!(
      name: "Jamie Reporter",
      email: "jamie-submitted@example.com",
      password: "password",
      role: "reporter",
      company: company
    )
  end

  let!(:other_reporter) do
    User.create!(
      name: "Other Reporter",
      email: "other-submitted@example.com",
      password: "password",
      role: "reporter",
      company: company
    )
  end

  let!(:technician) do
    User.create!(
      name: "Alex Technician",
      email: "alex-submitted@example.com",
      password: "password",
      role: "technician",
      company: company
    )
  end

  let!(:equipment) do
    Equipment.create!(
      name: "Water Pump",
      asset_identifier: "PUMP-SUBMITTED-01",
      location: "Building A",
      status: "Available"
    )
  end

  def create_ticket(title:, reporter:, assigned_technician: nil)
    MaintenanceTicket.create!(
      title: title,
      description: "Equipment requires maintenance",
      priority: "medium",
      status: "submitted",
      equipment: equipment,
      reporter: reporter,
      assigned_technician: assigned_technician
    )
  end

  describe "GET /issues" do
    before { sign_in reporter }

    it "shows only tickets submitted by the signed-in reporter" do
      create_ticket(title: "My Water Pump Issue", reporter: reporter)
      create_ticket(
        title: "Someone Else's Issue",
        reporter: other_reporter
      )

      get maintenance_tickets_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("My Water Pump Issue")
      expect(response.body).not_to include("Someone Else's Issue")
    end

    it "shows equipment, title, priority, status, and assignee" do
      create_ticket(
        title: "Pump Needs Repair",
        reporter: reporter,
        assigned_technician: technician
      )

      get maintenance_tickets_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Pump Needs Repair")
      expect(response.body).to include("Water Pump")
      expect(response.body).to include("Medium")
      expect(response.body).to include("Submitted")
      expect(response.body).to include("Alex Technician")
    end

    it "shows Unassigned when no technician is assigned" do
      create_ticket(
        title: "Unassigned Pump Issue",
        reporter: reporter
      )

      get maintenance_tickets_path

      expect(response.body).to include("Unassigned")
    end

    it "shows an empty-state message when the reporter has no tickets" do
      get maintenance_tickets_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No issues have been reported.")
    end

    it "provides a link to the ticket detail page" do
      ticket = create_ticket(
        title: "View My Ticket",
        reporter: reporter
      )

      get maintenance_tickets_path

      expect(response.body).to include(
        maintenance_ticket_path(ticket)
      )
    end
  end

  describe "GET /issues/:id" do
    before { sign_in reporter }

    it "allows a reporter to view their own ticket" do
      ticket = create_ticket(
        title: "My Detailed Ticket",
        reporter: reporter
      )

      get maintenance_ticket_path(ticket)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("My Detailed Ticket")
    end

    it "prevents a reporter from viewing another person's ticket" do
      ticket = create_ticket(
        title: "Private Ticket",
        reporter: other_reporter
      )

      get maintenance_ticket_path(ticket)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "unauthenticated access" do
    it "redirects users who are not signed in" do
      get maintenance_tickets_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
