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

    it "does not show the Devise login notice as priority feedback" do
      get maintenance_ticket_path(ticket)

      expect(response).to have_http_status(:ok)
      expect(flash[:notice]).to eq(I18n.t("devise.sessions.signed_in"))
      html = Nokogiri::HTML(response.body)
      expect(html.at_css(".ticket-priority-update [role='status']")).to be_nil
      expect(html.at_css(".ticket-page-feedback [role='status']")).to be_nil
    end

    %w[low medium high].each do |priority|
      it "persists #{priority} priority, including when unchanged" do
        update_priority(priority: priority)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(maintenance_ticket_path(ticket))
        expect(flash[:priority_update]).to eq("Ticket priority updated successfully.")
        expect(ticket.reload.priority).to eq(priority)
        expect(ticket.status).to eq("assigned")

        follow_redirect!

        html = Nokogiri::HTML(response.body)
        expect(html.at_css(".ticket-priority-update [role='status']").text)
          .to include("Ticket priority updated successfully.")
        expect(html.at_css(".ticket-page-feedback [role='status']").text)
          .to include("Ticket priority updated successfully.")
        expect(html.at_css("select[name='maintenance_ticket[priority]'] option[selected]")["value"])
          .to eq(priority)
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
        expect(html.at_css(".ticket-priority-update [role='alert']").text).to include("Priority")
        expect(html.at_css("select[name='maintenance_ticket[priority]']")["aria-invalid"]).to eq("true")
        expect(html.at_css("select[name='maintenance_ticket[priority]']")["aria-describedby"])
          .to eq("ticket-priority-errors")
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

    it "updates the correct manager queue row and reorders after promotion and demotion" do
      ticket.update!(created_at: 2.hours.ago)
      high_ticket = MaintenanceTicket.create!(
        title: "Existing high priority", description: "Needs attention", priority: "high",
        status: "submitted", equipment: equipment, reporter: reporter, created_at: 1.hour.ago
      )
      low_ticket = MaintenanceTicket.create!(
        title: "Existing low priority", description: "Can wait", priority: "low",
        status: "in_progress", equipment: equipment, reporter: reporter, created_at: 3.hours.ago
      )

      get manager_maintenance_tickets_path(sort: "priority")

      expect(response).to have_http_status(:ok)
      rows = Nokogiri::HTML(response.body).css(".ticket-queue tbody tr")
      expect(rows.map { |row| row.at_css("th a")["href"] }).to eq(
        [ high_ticket, ticket, low_ticket ].map { |record| maintenance_ticket_path(record) }
      )

      # Existing queue ordering uses creation time to break equal-priority ties.
      { "high" => [ ticket, high_ticket, low_ticket ],
        "low" => [ high_ticket, low_ticket, ticket ] }.each do |priority, expected_order|
        update_priority(priority: priority)

        expect(response).to have_http_status(:see_other)
        expect(ticket.reload.priority).to eq(priority)

        get manager_maintenance_tickets_path(sort: "priority")

        expect(response).to have_http_status(:ok)
        rows = Nokogiri::HTML(response.body).css(".ticket-queue tbody tr")
        expect(rows.map { |row| row.at_css("th a")["href"] })
          .to eq(expected_order.map { |record| maintenance_ticket_path(record) })
        rows.zip(expected_order).each do |row, record|
          expect(row.css("td")[2].text).to eq(record.priority.humanize)
        end
      end
    end

    %w[low medium high].each do |priority|
      it "shows the priority control with #{priority} preselected" do
        ticket.update!(priority: priority)

        get maintenance_ticket_path(ticket)

        expect(response).to have_http_status(:ok)
        html = Nokogiri::HTML(response.body)
        panel = html.at_css(".ticket-side-panels .ticket-priority-update")
        form = panel.at_css("form")
        selector = form.at_css("select[name='maintenance_ticket[priority]']")
        expect(panel.at_css("label")["for"]).to eq(selector["id"])
        expect(form["action"]).to eq(priority_maintenance_ticket_path(ticket))
        expect(form.at_css("input[name='_method']")["value"]).to eq("patch")
        expect(selector.css("option").map { |option| option["value"] })
          .to eq([ "", "low", "medium", "high" ])
        expect(selector.at_css("option[selected]")["value"]).to eq(priority)
        expect(form.at_css("input[type='submit']")["value"]).to eq("Update priority")
        expect(html.at_css(".ticket-status-update")).to be_present
      end
    end
  end

  %w[technician reporter].each do |role|
    context "as a #{role}" do
      before { log_in(public_send(role)) }

      it "shows priority information without the priority control" do
        get maintenance_ticket_path(ticket)

        expect(response).to have_http_status(:ok)
        html = Nokogiri::HTML(response.body)
        expect(html.at_css(".ticket-priority-update")).to be_nil
        expect(html.at_css("select[name='maintenance_ticket[priority]']")).to be_nil
        expect(html.at_css(".ticket-details").text).to include("Priority", "Medium")
        expect(html.at_css(".ticket-status-update")).to be_present
        if role == "technician"
          expect(html.at_css("form[data-repair-add-form]")).to be_present
        end
      end

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
