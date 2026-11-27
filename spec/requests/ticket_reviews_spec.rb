
require "rails_helper"

RSpec.describe "Verify or Reopen a Repaired Ticket", type: :request do
  let!(:company) { Company.create!(name: "Review Test Company") }
  let!(:other_company) { Company.create!(name: "Other Company") }

  let!(:reporter) do
    User.create!(
      name: "Jamie Reporter",
      email: "review-reporter@example.com",
      password: "password",
      role: "reporter",
      company: company
    )
  end

  let!(:other_reporter) do
    User.create!(
      name: "Other Reporter",
      email: "review-other@example.com",
      password: "password",
      role: "reporter",
      company: company
    )
  end

  let!(:technician) do
    User.create!(
      name: "Alex Technician",
      email: "review-technician@example.com",
      password: "password",
      role: "technician",
      company: company
    )
  end

  let!(:manager) do
    User.create!(
      name: "Review Manager",
      email: "review-manager@example.com",
      password: "password",
      role: "manager",
      company: company
    )
  end

  let!(:outside_manager) do
    User.create!(
      name: "Outside Manager",
      email: "outside-manager@example.com",
      password: "password",
      role: "manager",
      company: other_company
    )
  end

  let!(:equipment) do
    Equipment.create!(
      name: "Water Pump",
      asset_identifier: "PUMP-REVIEW-001",
      location: "Building A",
      status: "Available"
    )
  end

  let!(:ticket) do
    MaintenanceTicket.create!(
      title: "Pump repair",
      description: "Pump is broken",
      priority: "medium",
      status: "ready_for_verification",
      equipment: equipment,
      reporter: reporter,
      assigned_technician: technician
    )
  end

  describe "PATCH verify" do
    before { sign_in reporter }

    it "closes a repaired ticket and creates an audit record" do
      expect do
        patch verify_maintenance_ticket_path(ticket)
      end.to change(TicketReviewEvent, :count).by(1)

      expect(ticket.reload.status).to eq("closed")

      event = ticket.ticket_review_events.last
      expect(event.event_type).to eq("verified")
      expect(event.actor).to eq(reporter)
      expect(event.previous_status).to eq("ready_for_verification")
      expect(event.new_status).to eq("closed")
    end

    it "rejects verification from an invalid status" do
      ticket.update!(status: "assigned")

      patch verify_maintenance_ticket_path(ticket)

      expect(ticket.reload.status).to eq("assigned")
      expect(TicketReviewEvent.count).to eq(0)
    end
  end

  describe "PATCH reopen" do
    before { sign_in reporter }

    it "requires a reason" do
      patch reopen_maintenance_ticket_path(ticket),
            params: { reason: "" }

      expect(ticket.reload.status).to eq("ready_for_verification")
      expect(TicketReviewEvent.count).to eq(0)
    end

    it "reopens the ticket and saves the reason" do
      patch reopen_maintenance_ticket_path(ticket),
            params: { reason: "The pump still leaks." }

      expect(ticket.reload.status).to eq("in_progress")

      event = ticket.ticket_review_events.last

      expect(event.event_type).to eq("reopened")
      expect(event.reason).to eq("The pump still leaks.")
      expect(event.actor).to eq(reporter)
      expect(event.previous_status).to eq("ready_for_verification")
      expect(event.new_status).to eq("in_progress")
    end

    it "preserves existing repair records" do
      record = RepairRecord.create!(
        maintenance_ticket: ticket,
        technician: technician,
        title: "Replaced seal",
        description: "Installed a new seal"
      )

      patch reopen_maintenance_ticket_path(ticket),
            params: { reason: "Still leaking" }

      expect(RepairRecord.exists?(record.id)).to be(true)
      expect(ticket.reload.status).to eq("in_progress")
    end

    it "allows reopening a closed ticket" do
      ticket.update!(status: "closed")

      patch reopen_maintenance_ticket_path(ticket),
            params: { reason: "Problem returned" }

      expect(ticket.reload.status).to eq("in_progress")
    end
  end

  describe "authorization" do
    it "rejects another reporter" do
      sign_in other_reporter

      patch verify_maintenance_ticket_path(ticket)

      expect(response).to have_http_status(:forbidden)
      expect(ticket.reload.status).to eq("ready_for_verification")
      expect(TicketReviewEvent.count).to eq(0)
    end

    it "rejects technicians from verifying a ticket" do
      sign_in technician

      patch verify_maintenance_ticket_path(ticket)

      expect(response).to have_http_status(:forbidden)
      expect(ticket.reload.status).to eq("ready_for_verification")
    end

    it "requires a manager override reason" do
      sign_in manager

      patch verify_maintenance_ticket_path(ticket)

      expect(ticket.reload.status).to eq("ready_for_verification")
      expect(TicketReviewEvent.count).to eq(0)
    end

    it "records a manager override" do
      sign_in manager

      patch verify_maintenance_ticket_path(ticket),
            params: {
              reason: "Inspected the repair on behalf of the reporter"
            }

      expect(ticket.reload.status).to eq("closed")

      event = ticket.ticket_review_events.last

      expect(event.manager_override).to be(true)
      expect(event.actor).to eq(manager)
      expect(event.reason).to be_present
    end

    it "rejects managers from another company" do
      sign_in outside_manager

      patch reopen_maintenance_ticket_path(ticket),
            params: { reason: "Unauthorized override" }

      expect(response).to have_http_status(:forbidden)
      expect(ticket.reload.status).to eq("ready_for_verification")
      expect(TicketReviewEvent.count).to eq(0)
    end

    it "requires authentication" do
      patch verify_maintenance_ticket_path(ticket)

      expect(response).to redirect_to(new_user_session_path)
      expect(ticket.reload.status).to eq("ready_for_verification")
    end
  end
end
