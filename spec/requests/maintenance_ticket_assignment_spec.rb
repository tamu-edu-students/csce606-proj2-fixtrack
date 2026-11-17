# Exercises ticket assignment through real Devise login and HTTP requests.
# Covers permissions, validation, saved assignments, and user-facing feedback.
# Verifies queue updates and technician access after reassignment or clearing.
require "rails_helper"

RSpec.describe "Ticket technician assignment", type: :request do
  let(:manager) { assignment_user("manager") }
  let(:reporter) { assignment_user("reporter") }
  let!(:technician) { assignment_user("technician") }
  let(:replacement) { assignment_user("technician", "replacement") }
  let(:equipment) do
    Equipment.create!(name: "Pump", asset_identifier: "ASSIGNMENT-REQUEST-1",
                      location: "Building A", status: "Available")
  end
  let!(:ticket) do
    MaintenanceTicket.create!(title: "Pump failure", description: "The pump will not start.",
                              priority: "high", status: "submitted", equipment: equipment, reporter: reporter)
  end

  def assignment_user(role, identifier = role)
    User.create!(name: identifier.humanize, email: "assignment-request-#{identifier}@example.com",
                 password: "password123", role: role)
  end

  def log_in(user, session: self)
    # Exercise Devise authentication rather than stubbing current_user.
    session.post user_session_path, params: { user: { email: user.email, password: "password123" } }
    expect(session.response).to have_http_status(:see_other)
    expect(URI.parse(session.response.location).path).to eq(root_path)
  end

  def assign_technician(id, session: self, **extra_attributes)
    session.patch assignment_maintenance_ticket_path(ticket, repair_records_order: "desc"),
                  params: { maintenance_ticket: extra_attributes.merge(assigned_technician_id: id) }
  end

  def signed_in_session(user)
    session = ActionDispatch::Integration::Session.new(Rails.application)
    log_in(user, session: session)
    session
  end

  def expect_ticket_visibility(session, visible:)
    session.get maintenance_tickets_path
    expect(session.response).to have_http_status(:ok)
    links = Nokogiri::HTML(session.response.body).css("tbody a").map { |link| link["href"] }
    expect(links.include?(maintenance_ticket_path(ticket))).to eq(visible)
    session.get maintenance_ticket_path(ticket)
    expect(session.response).to have_http_status(visible ? :ok : :not_found)
    if visible
      html = Nokogiri::HTML(session.response.body)
      expect(html.at_css(".ticket-details__assignee dd").text).to eq(ticket.reload.assigned_technician.name)
      expect(html.at_css("form[data-repair-add-form]")).to be_present
      expect(html.at_css(".ticket-technician-assignment")).to be_nil
    end
  end

  context "assignment requests" do
    context "as a manager" do
      before { log_in(manager) }

      [ :initial, :reassignment ].each do |operation|
        it "rejects invalid assignees on #{operation} without changing persisted data" do
          ticket.update!(status: "assigned", assigned_technician: technician) if operation == :reassignment
          original_attributes = ticket.attributes
          [ reporter.id, User.maximum(:id) + 1, "#{technician.id}invalid" ].each do |id|
            assign_technician(id)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to include("must be an existing technician")
            expect(ticket.reload.attributes).to eq(original_attributes)
          end
        end
      end

      it "renders accessible errors with the saved selection, without normalizing status or changing repairs" do
        ticket.update!(status: "assigned", assigned_technician: technician)
        repair = ticket.repair_records.create!(technician: technician, title: "Inspection", description: "Checked pump.")
        original_attributes, original_repair = ticket.attributes, repair.attributes
        assign_technician(reporter.id)

        expect(response).to have_http_status(:unprocessable_entity)
        html = Nokogiri::HTML(response.body)
        expect(html.at_css("#ticket-details-title").text).to include(ticket.title)
        expect(html.at_css(".ticket-priority-update")).to be_present
        expect(html.at_css(".ticket-status-update")).to be_present
        expect(html.at_css("th[aria-sort]")["aria-sort"]).to eq("descending")
        expect(html.at_css("#ticket-assignment-errors").text).to include("must be an existing technician")
        selector = html.at_css(".ticket-technician-assignment select")
        expect(selector["aria-invalid"]).to eq("true")
        expect(selector["aria-describedby"].split).to include("ticket-assignment-errors")
        expect(selector.at_css("option[selected]")["value"]).to eq(technician.id.to_s)
        expect(html.at_css(".ticket-details__assignee dd").text).to eq(technician.name)
        expect(flash[:technician_assignment]).to be_nil
        expect(ticket.reload.attributes).to eq(original_attributes)
        expect(ticket.repair_records.count).to eq(1)
        expect(repair.reload.attributes).to eq(original_repair)
      end

      it "ignores fields other than the intended assignee" do
        original_attributes = ticket.attributes.except("assigned_technician_id", "status", "updated_at")
        assign_technician(technician.id, status: "closed", priority: "low", reporter_id: technician.id,
                         equipment_id: -1, title: "Changed", description: "Changed",
                         repair_records_attributes: [ { title: "Injected repair" } ])

        expect(response).to have_http_status(:see_other)
        expect(ticket.reload.assigned_technician).to eq(technician)
        expect(ticket.status).to eq("assigned")
        expect(ticket.attributes.except("assigned_technician_id", "status", "updated_at")).to eq(original_attributes)
        expect(ticket.repair_records.count).to eq(0)
      end

      [ {}, { maintenance_ticket: {} }, { maintenance_ticket: { title: "Ignored" } },
        { maintenance_ticket: "invalid" }, { maintenance_ticket: { assigned_technician_id: [] } },
        { maintenance_ticket: { assigned_technician_id: { id: 1 } } } ].each do |parameters|
        it "returns 400 for malformed parameters #{parameters.inspect} without clearing the assignment" do
          ticket.update!(status: "assigned", assigned_technician: technician)
          original_attributes = ticket.attributes
          patch assignment_maintenance_ticket_path(ticket), params: parameters
          expect(response).to have_http_status(:bad_request)
          expect(ticket.reload.attributes).to eq(original_attributes)
        end
      end

      %w[rejected ready_for_verification closed].each do |status|
        it "rejects assignment in #{status}" do
          ticket.update!(status: status)
          original_attributes = ticket.attributes
          assign_technician(technician.id)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("does not allow technician assignment changes")
          expect(ticket.reload.attributes).to eq(original_attributes)
        end
      end

      it "accepts JSON null for clearing without resetting work in progress" do
        ticket.update!(status: "in_progress", assigned_technician: technician)
        patch assignment_maintenance_ticket_path(ticket),
              params: { maintenance_ticket: { assigned_technician_id: nil } }, as: :json
        expect(response).to have_http_status(:see_other)
        expect(ticket.reload.assigned_technician).to be_nil
        expect(ticket.status).to eq("in_progress")
      end

      it "returns 404 for a nonexistent ticket" do
        patch assignment_maintenance_ticket_path(-1), params: { maintenance_ticket: { assigned_technician_id: technician.id } }
        expect(response).to have_http_status(:not_found)
      end
    end

    %w[technician reporter].each do |role|
      it "denies assignment, reassignment, clearing, and malformed requests by a #{role}" do
        log_in(public_send(role))
        [ technician.id, replacement.id, "", :missing ].each do |id|
          original_attributes = ticket.reload.attributes
          if id == :missing
            patch assignment_maintenance_ticket_path(ticket), params: {}
          else
            assign_technician(id)
          end
          expect(response).to have_http_status(:forbidden)
          expect(ticket.reload.attributes).to eq(original_attributes)
          ticket.update!(status: "assigned", assigned_technician: technician)
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

  context "assignment controls and feedback" do
    %w[manager admin].each do |role|
      it "shows eligible technicians and the saved selection to a #{role}, before priority controls" do
        # Admin authorization is supported without introducing role provisioning.
        manager.update_column(:role, "admin") if role == "admin"
        log_in(manager)
        ticket.update!(status: "assigned", assigned_technician: technician)
        replacement.update!(name: technician.name)
        get maintenance_ticket_path(ticket)

        expect(response).to have_http_status(:ok)
        html = Nokogiri::HTML(response.body)
        panel = html.at_css(".ticket-technician-assignment")
        expect(panel.next_element["class"]).to include("ticket-priority-update")
        selector = panel.at_css("select")
        expect(panel.at_css("label")["for"]).to eq(selector["id"])
        expect(selector.css("option").map { |option| option["value"] }).to eq([ "", replacement.id.to_s, technician.id.to_s ])
        expect(selector.text).to include("Unassigned", technician.email, replacement.email)
        expect(selector.at_css("option[selected]")["value"]).to eq(technician.id.to_s)
        expect(html.at_css(".ticket-details__assignee dd").text).to eq(technician.name)
        expect(panel.at_css("[role='status']")).to be_nil
        expect(html.at_css(".ticket-page-feedback [role='status']")).to be_nil
      end
    end

    it "shows saved assignment and clearing results with dedicated feedback" do
      log_in(manager)
      [ [ technician.id, technician.name, "assigned" ], [ "", "Unassigned", "submitted" ] ].each do |id, name, status|
        assign_technician(id)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(maintenance_ticket_path(ticket))
        follow_redirect!
        expect(response).to have_http_status(:ok)
        html = Nokogiri::HTML(response.body)
        expect(html.at_css(".ticket-details__assignee dd").text).to eq(name)
        expect(ticket.reload.assigned_technician&.name || "Unassigned").to eq(name)
        expect(ticket.status).to eq(status)
        expect(html.at_css(".ticket-technician-assignment [role='status']").text).to include("updated successfully")
        expect(html.at_css(".ticket-page-feedback [role='status']").text).to include("updated successfully")
        expect(html.at_css(".ticket-priority-update [role='status']")).to be_nil
      end
    end

    it "disables assignment when no technicians are available" do
      log_in(manager)
      technician.destroy!
      get maintenance_ticket_path(ticket)
      panel = Nokogiri::HTML(response.body).at_css(".ticket-technician-assignment")
      expect(panel.text).to include("No technicians are available for assignment.")
      expect(panel.at_css("select")["disabled"]).to be_present
      expect(panel.at_css("input[type='submit']")["disabled"]).to be_present
    end

    it "explains restricted statuses instead of offering an assignment form" do
      log_in(manager)
      ticket.update!(status: "closed")
      get maintenance_ticket_path(ticket)
      panel = Nokogiri::HTML(response.body).at_css(".ticket-technician-assignment")
      expect(panel.text).to include("Assignments can only be changed")
      expect(panel.at_css("form")).to be_nil
    end

    %w[technician reporter].each do |role|
      it "shows the assignee without assignment controls to a #{role}" do
        ticket.update!(status: "assigned", assigned_technician: technician)
        log_in(public_send(role))
        get maintenance_ticket_path(ticket)
        expect(response).to have_http_status(:ok)
        html = Nokogiri::HTML(response.body)
        expect(html.at_css(".ticket-details__assignee dd").text).to eq(technician.name)
        expect(html.at_css(".ticket-technician-assignment")).to be_nil
      end
    end
  end

  context "queue updates and technician access" do
    %w[manager admin].each do |role|
      it "updates only the intended #{role} queue row after assignment, rejection, reassignment, and clearing" do
        manager.update_column(:role, "admin") if role == "admin"
        session = signed_in_session(manager)
        # Identical titles ensure the check identifies rows by ticket ID.
        other = MaintenanceTicket.create!(title: ticket.title, description: "Separate failure.", priority: "low",
                                          status: "assigned", equipment: equipment, reporter: reporter, assigned_technician: replacement)
        original_other = other.attributes
        [ [ technician.id, :see_other, technician.name, "Assigned" ],
          [ reporter.id, :unprocessable_entity, technician.name, "Assigned" ],
          [ replacement.id, :see_other, replacement.name, "Assigned" ],
          [ "", :see_other, "Unassigned", "Submitted" ] ].each do |id, response_status, name, status|
          assign_technician(id, session: session)
          expect(session.response).to have_http_status(response_status)
          expect(ticket.reload.assigned_technician&.name || "Unassigned").to eq(name)
          session.get manager_maintenance_tickets_path
          expect(session.response).to have_http_status(:ok)
          rows = Nokogiri::HTML(session.response.body).css(".ticket-queue tbody tr")
          row = rows.find { |entry| entry.at_css("th a")["href"] == maintenance_ticket_path(ticket) }
          expect(row.css("td")[3..4].map(&:text)).to eq([ status, name ])
          expect(other.reload.attributes).to eq(original_other)
        end
      end
    end

    it "transfers technician visibility and repair access, then removes access when cleared" do
      manager_session = signed_in_session(manager)
      original_session = signed_in_session(technician)
      replacement_session = signed_in_session(replacement)
      expect_ticket_visibility(original_session, visible: false)
      assign_technician(technician.id, session: manager_session)
      expect(manager_session.response).to have_http_status(:see_other)
      expect_ticket_visibility(original_session, visible: true)
      expect_ticket_visibility(replacement_session, visible: false)
      ticket.update!(status: "in_progress")
      repair = ticket.repair_records.create!(technician: technician, title: "Inspection", description: "Original findings.")
      original_repair = repair.attributes
      assign_technician(replacement.id, session: manager_session)
      expect(manager_session.response).to have_http_status(:see_other)
      expect(ticket.reload.status).to eq("in_progress")
      expect_ticket_visibility(original_session, visible: false)
      expect_ticket_visibility(replacement_session, visible: true)
      original_session.post maintenance_ticket_repair_records_path(ticket), params: { repair_record: { title: "Unauthorized" } }
      expect(original_session.response).to have_http_status(:not_found)
      original_session.patch maintenance_ticket_repair_record_path(ticket, repair), params: { repair_record: { title: "Unauthorized" } }
      expect(original_session.response).to have_http_status(:not_found)
      original_session.delete maintenance_ticket_repair_record_path(ticket, repair)
      expect(original_session.response).to have_http_status(:not_found)
      assign_technician("", session: manager_session)
      expect(manager_session.response).to have_http_status(:see_other)
      expect(ticket.reload.assigned_technician).to be_nil
      expect(ticket.status).to eq("in_progress")
      expect_ticket_visibility(original_session, visible: false)
      expect_ticket_visibility(replacement_session, visible: false)
      expect(ticket.repair_records.count).to eq(1)
      expect(repair.reload.attributes).to eq(original_repair)
    end

    it "retains reporter access after handoff without retaining the former technician's repair editor" do
      ticket.update!(status: "assigned", assigned_technician: technician, reporter: technician)
      original_session = signed_in_session(technician)
      assign_technician(replacement.id, session: signed_in_session(manager))
      expect(ticket.reload.assigned_technician).to eq(replacement)
      original_session.get maintenance_ticket_path(ticket)
      expect(original_session.response).to have_http_status(:ok)
      html = Nokogiri::HTML(original_session.response.body)
      expect(html.at_css(".ticket-details__assignee dd").text).to eq(replacement.name)
      expect(html.at_css("form[data-repair-add-form]")).to be_nil
    end
  end
end
