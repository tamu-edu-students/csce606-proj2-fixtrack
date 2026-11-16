require "rails_helper"

RSpec.describe "Ticket technician assignment", type: :request do
  let(:reporter) { assignment_user("reporter") }
  let!(:technician) { assignment_user("technician") }
  let(:replacement) { assignment_user("technician", "replacement") }
  let(:equipment) do
    Equipment.create!(name: "Pump", asset_identifier: "ASSIGNMENT-REQUEST-1",
                      location: "Building A", status: "Available")
  end
  let!(:ticket) do
    MaintenanceTicket.create!(title: "Pump failure", description: "The pump will not start.",
                              priority: "high", status: "submitted",
                              equipment: equipment, reporter: reporter)
  end

  def assignment_user(role, identifier = role)
    User.create!(name: identifier.humanize, email: "assignment-request-#{identifier}@example.com",
                 password: "password123", role: role)
  end

  def log_in(user)
    # Exercise authentication through Devise rather than stubbing current_user.
    post user_session_path, params: { user: { email: user.email, password: "password123" } }
    expect(response).to redirect_to(root_path)
  end

  def assign_technician(id, **extra_attributes)
    patch assignment_maintenance_ticket_path(ticket, repair_records_order: "desc"),
          params: { maintenance_ticket: extra_attributes.merge(assigned_technician_id: id) }
  end

  %w[manager admin].each do |role|
    context "as a #{role}" do
      before do
        user = assignment_user("manager")
        # Admin authorization is supported without adding role provisioning.
        user.update_column(:role, "admin") if role == "admin"
        log_in(user)
      end

      it "persists initial assignment and status and redirects with dedicated feedback" do
        original_attributes = ticket.attributes.except("assigned_technician_id", "status", "updated_at")

        assign_technician(technician.id.to_s)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(maintenance_ticket_path(ticket))
        expect(flash[:technician_assignment]).to eq("Ticket technician assignment updated successfully.")
        expect(flash[:priority_update]).to be_nil
        expect(ticket.reload.assigned_technician).to eq(technician)
        expect(ticket.status).to eq("assigned")
        expect(ticket.attributes.except("assigned_technician_id", "status", "updated_at"))
          .to eq(original_attributes)
      end

      it "reassigns in-progress work while preserving repair records and ticket fields" do
        ticket.update!(status: "in_progress", assigned_technician: technician)
        repair = ticket.repair_records.create!(technician: technician, title: "Inspection",
                                              description: "Checked the pump.")
        original_repair = repair.attributes
        original_attributes = ticket.attributes.except("assigned_technician_id", "updated_at")

        assign_technician(replacement.id)

        expect(response).to have_http_status(:see_other)
        expect(ticket.reload.assigned_technician).to eq(replacement)
        expect(ticket.attributes.except("assigned_technician_id", "updated_at")).to eq(original_attributes)
        expect(ticket.repair_records.count).to eq(1)
        expect(repair.reload.attributes).to eq(original_repair)
      end

      it "clears an assigned ticket and returns it to submitted" do
        ticket.update!(status: "assigned", assigned_technician: technician)

        assign_technician("")

        expect(response).to have_http_status(:see_other)
        expect(ticket.reload.assigned_technician).to be_nil
        expect(ticket.status).to eq("submitted")
      end

      it "accepts explicit JSON null for clearing without resetting work in progress" do
        ticket.update!(status: "in_progress", assigned_technician: technician)

        patch assignment_maintenance_ticket_path(ticket),
              params: { maintenance_ticket: { assigned_technician_id: nil } }, as: :json

        expect(response).to have_http_status(:see_other)
        expect(ticket.reload.assigned_technician).to be_nil
        expect(ticket.status).to eq("in_progress")
      end

      [ :nonexistent, :reporter, :malformed ].each do |invalid_assignee|
        [ :initial, :reassignment ].each do |operation|
          it "rejects #{invalid_assignee} on #{operation} and renders ticket details" do
            ticket.update!(status: "assigned", assigned_technician: technician) if operation == :reassignment
            original_attributes = ticket.attributes
            id = case invalid_assignee
            when :nonexistent then User.maximum(:id) + 1
            when :reporter then reporter.id
            else "#{technician.id}invalid"
            end

            assign_technician(id)

            expect(response).to have_http_status(:unprocessable_entity)
            html = Nokogiri::HTML(response.body)
            expect(html.at_css(".ticket-page-feedback [role='alert']").text)
              .to include("must be an existing technician")
            expect(html.at_css("#ticket-details-title").text).to include(ticket.title)
            expect(html.at_css(".ticket-repair-history")).to be_present
            expect(html.at_css(".ticket-status-update")).to be_present
            expect(html.at_css(".ticket-priority-update")).to be_present
            expect(flash[:technician_assignment]).to be_nil
            expect(ticket.reload.attributes).to eq(original_attributes)
          end
        end
      end

      it "does not invoke show or normalize status when rendering validation errors" do
        ticket.update!(status: "assigned", assigned_technician: technician)
        repair = ticket.repair_records.create!(technician: technician, title: "Inspection",
                                              description: "Checked the pump.")
        original_attributes = ticket.attributes
        original_repair = repair.attributes

        assign_technician(reporter.id)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Inspection", "Checked the pump.")
        html = Nokogiri::HTML(response.body)
        expect(html.at_css("th[aria-sort]")["aria-sort"]).to eq("descending")
        expect(ticket.reload.attributes).to eq(original_attributes)
        expect(ticket.repair_records.count).to eq(1)
        expect(repair.reload.attributes).to eq(original_repair)
      end

      %w[rejected ready_for_verification closed].each do |status|
        it "rejects assignment in #{status} without changing the ticket" do
          ticket.update!(status: status)
          original_attributes = ticket.attributes

          assign_technician(technician.id)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("does not allow technician assignment changes")
          expect(ticket.reload.attributes).to eq(original_attributes)
        end
      end

      it "ignores ticket fields other than the intended assignee" do
        original_attributes = ticket.attributes.except("assigned_technician_id", "status", "updated_at")

        assign_technician(technician.id, status: "closed", priority: "low", reporter_id: technician.id,
                         equipment_id: -1, title: "Changed", description: "Changed",
                         repair_records_attributes: [ { title: "Injected repair" } ])

        expect(response).to have_http_status(:see_other)
        expect(ticket.reload.assigned_technician).to eq(technician)
        expect(ticket.status).to eq("assigned")
        expect(ticket.attributes.except("assigned_technician_id", "status", "updated_at"))
          .to eq(original_attributes)
        expect(ticket.repair_records.count).to eq(0)
      end

      [ {}, { maintenance_ticket: {} }, { maintenance_ticket: { title: "Ignored" } },
        { maintenance_ticket: "invalid" }, { maintenance_ticket: { assigned_technician_id: [] } },
        { maintenance_ticket: { assigned_technician_id: { id: 1 } } } ].each do |parameters|
        it "returns 400 for malformed parameters #{parameters.inspect} without clearing an assignment" do
          ticket.update!(status: "assigned", assigned_technician: technician)
          original_attributes = ticket.attributes

          patch assignment_maintenance_ticket_path(ticket), params: parameters

          expect(response).to have_http_status(:bad_request)
          expect(ticket.reload.attributes).to eq(original_attributes)
        end
      end

      it "returns 404 for a nonexistent ticket" do
        patch assignment_maintenance_ticket_path(-1),
              params: { maintenance_ticket: { assigned_technician_id: technician.id } }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  %w[technician reporter].each do |role|
    context "as a #{role}" do
      before { log_in(public_send(role)) }

      [ :assign, :reassign, :clear ].each do |operation|
        it "forbids #{operation} and preserves persisted ticket data" do
          ticket.update!(status: "assigned", assigned_technician: technician) unless operation == :assign
          original_attributes = ticket.attributes

          assign_technician(operation == :clear ? "" : replacement.id)

          expect(response).to have_http_status(:forbidden)
          expect(ticket.reload.attributes).to eq(original_attributes)
        end
      end

      it "authorizes before attempting parameter validation" do
        patch assignment_maintenance_ticket_path(ticket), params: {}

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  it "redirects signed-out requests to Devise without changing the ticket" do
    original_attributes = ticket.attributes

    assign_technician(technician.id)

    expect(response).to redirect_to(new_user_session_path)
    expect(ticket.reload.attributes).to eq(original_attributes)
  end
end
