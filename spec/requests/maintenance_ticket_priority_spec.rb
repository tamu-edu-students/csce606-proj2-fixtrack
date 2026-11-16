require "rails_helper"

RSpec.describe "Ticket priority updates", type: :request do
  let(:manager) { create_user("manager") }
  let(:reporter) { create_user("reporter") }
  let(:technician) { create_user("technician") }
  let(:equipment) do
    Equipment.create!(name: "Pump", asset_identifier: "PRIORITY-1",
                      location: "Building A", status: "Available")
  end
  let!(:ticket) do
    MaintenanceTicket.create!(title: "Pump failure", description: "The pump will not start.",
                              priority: "medium", status: "assigned", equipment: equipment,
                              reporter: reporter, assigned_technician: technician)
  end

  def create_user(role)
    User.create!(name: role.humanize, email: "priority-#{role}@example.com",
                 password: "password123", role: role)
  end

  def log_in(user)
    # Use the real Devise session endpoint so authentication is exercised too.
    post user_session_path, params: { user: { email: user.email, password: "password123" } }
    expect(response).to redirect_to(root_path)
  end

  def update_priority(repair_records_order: nil, **attributes)
    patch priority_maintenance_ticket_path(ticket, repair_records_order: repair_records_order),
          params: { maintenance_ticket: attributes }
  end

  context "as a manager" do
    before { log_in(manager) }

    %w[low medium high].each do |priority|
      it "persists #{priority} priority, including when unchanged" do
        update_priority(priority: priority)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(maintenance_ticket_path(ticket))
        expect(flash[:notice]).to eq("Ticket priority updated successfully.")
        expect(ticket.reload.priority).to eq(priority)
        expect(ticket.status).to eq("assigned")
      end
    end

    [ "", "urgent" ].each do |priority|
      it "renders the complete detail page for #{priority.inspect} without changing the ticket" do
        original_attributes = ticket.attributes

        update_priority(priority: priority, repair_records_order: "desc")

        expect(response).to have_http_status(:unprocessable_entity)
        html = Nokogiri::HTML(response.body)
        expect(html.at_css("[role='alert']").text).to include("Priority")
        expect(html.at_css("#ticket-details-title").text).to eq(ticket.title)
        expect(html.at_css(".ticket-repair-history")).to be_present
        expect(html.at_css(".ticket-status-update")).to be_present
        expect(ticket.reload.attributes).to eq(original_attributes)
      end
    end

    it "does not normalize status or alter repair records on validation failure" do
      repair = ticket.repair_records.create!(technician: technician, title: "Inspection",
                                            description: "Checked the pump.")
      original_repair = repair.attributes

      update_priority(priority: "urgent")

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Inspection", "Checked the pump.")
      expect(ticket.reload.status).to eq("assigned")
      expect(repair.reload.attributes).to eq(original_repair)
      expect(ticket.repair_records.count).to eq(1)
    end

    it "does not normalize status or alter repair records on success" do
      repair = ticket.repair_records.create!(technician: technician, title: "Inspection",
                                            description: "Checked the pump.")
      original_repair = repair.attributes

      update_priority(priority: "high")

      expect(response).to have_http_status(:see_other)
      expect(ticket.reload.status).to eq("assigned")
      expect(repair.reload.attributes).to eq(original_repair)
      expect(ticket.repair_records.count).to eq(1)
    end

    it "ignores fields other than priority" do
      original_attributes = ticket.attributes.except("priority", "updated_at")

      update_priority(priority: "high", status: "closed", assigned_technician_id: manager.id,
                      reporter_id: manager.id, equipment_id: -1,
                      title: "Changed title", description: "Changed description")

      expect(response).to have_http_status(:see_other)
      expect(ticket.reload.priority).to eq("high")
      expect(ticket.attributes.except("priority", "updated_at")).to eq(original_attributes)
    end

    [ {}, { maintenance_ticket: {} }, { maintenance_ticket: { title: "Ignored" } },
      { maintenance_ticket: "invalid" } ].each do |parameters|
      it "returns 400 for missing required parameters: #{parameters.inspect}" do
        patch priority_maintenance_ticket_path(ticket), params: parameters

        expect(response).to have_http_status(:bad_request)
        expect(ticket.reload.priority).to eq("medium")
      end
    end

    it "returns 404 for a missing ticket" do
      patch priority_maintenance_ticket_path(-1), params: { maintenance_ticket: { priority: "high" } }

      expect(response).to have_http_status(:not_found)
    end
  end

  %w[technician reporter].each do |role|
    context "as a #{role}" do
      before { log_in(public_send(role)) }

      it "returns 403 without changing the ticket" do
        original_attributes = ticket.attributes

        update_priority(priority: "high")

        expect(response).to have_http_status(:forbidden)
        expect(ticket.reload.attributes).to eq(original_attributes)
      end
    end
  end

  it "redirects signed-out requests to login without changing the ticket" do
    update_priority(priority: "high")

    expect(response).to redirect_to(new_user_session_path)
    expect(ticket.reload.priority).to eq("medium")
  end
end
