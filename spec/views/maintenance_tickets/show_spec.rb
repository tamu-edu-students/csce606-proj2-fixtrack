require "rails_helper"

RSpec.describe "maintenance_tickets/show", type: :view do
  let(:equipment) do
    Equipment.create!(
      name: "Water Pump",
      asset_identifier: "PUMP-001",
      location: "Building A",
      status: "Available"
    )
  end
  let(:reporter) do
    User.create!(
      name: "Jamie Reporter",
      email: "jamie@example.com",
      password: "password",
      role: "reporter"
    )
  end
  let(:ticket) do
    MaintenanceTicket.create!(
      title: "Pump overheats",
      description: "The pump stops during operation.",
      priority: "high",
      status: "in_progress",
      equipment: equipment,
      reporter: reporter
    )
  end

  before do
    view.define_singleton_method(:current_user) { nil }
  end

  describe "shared information" do
    it "renders ticket details and links to the associated equipment" do
      render partial: "maintenance_tickets/shared_information", locals: { ticket: ticket }
      html = Nokogiri::HTML.fragment(rendered)

      expect(html.at_css("h1").text).to eq("Pump overheats")
      expect(html.at_css("dl").text).to include(
        "Ticket ID", ticket.id.to_s,
        "Equipment", "Water Pump",
        "Equipment Identifier", "PUMP-001",
        "Issue Description", "The pump stops during operation.",
        "Priority", "High",
        "Status", "In progress",
        "Reported By", "Jamie Reporter",
        "Created", "Last Updated"
      )
      expect(html.at_css("a[href='#{equipment_path(equipment)}']").text).to eq("PUMP-001")
    end

    it "escapes ticket title and description instead of rendering markup" do
      ticket.update!(
        title: "<script>alert('title')</script>",
        description: "<img src=x onerror=alert('description')>"
      )

      render partial: "maintenance_tickets/shared_information", locals: { ticket: ticket }
      html = Nokogiri::HTML.fragment(rendered)

      expect(html.css("script, img")).to be_empty
      expect(html.text).to include("<script>alert('title')</script>")
      expect(html.text).to include("<img src=x onerror=alert('description')>")
    end
  end

  describe "repair records" do
    let(:technician) do
      User.create!(
        name: "Taylor Technician",
        email: "taylor@example.com",
        password: "password",
        role: "technician"
      )
    end

    let!(:oldest_repair_record) do
      ticket.repair_records.create!(
        technician: technician,
        title: "Initial repair",
        description: "Replaced the motor.",
        created_at: Time.zone.parse("2026-11-15 09:00")
      )
    end
    let!(:newest_repair_record) do
      ticket.repair_records.create!(
        technician: technician,
        title: "Follow-up repair",
        description: "Adjusted the motor.",
        created_at: Time.zone.parse("2026-11-16 09:00")
      )
    end

    it "shows oldest records first with expandable titles and recorded times" do
      render partial: "maintenance_tickets/repair_records",
             locals: { ticket: ticket, order: "asc" }
      html = Nokogiri::HTML.fragment(rendered)
      table = html.at_css("table.ticket-repair-history__table")
      rows = table.css("tbody tr")

      expect(html.at_css("h2").text).to eq("Repairs")
      expect(html.css("ul, ol")).to be_empty
      expect(table.css("th").map { |header| header.text.gsub(/\s+/, " ").strip }).to eq(
        [ "Repair Expand all", "Recorded at ↑" ]
      )
      expect(table.at_css("[data-repair-records-toggle]")["aria-expanded"]).to eq("false")
      expect(table.css("details[open]")).to be_empty
      expect(table.at_css("th[aria-sort='ascending']")).to be_present
      expect(rows.map { |row| row.at_css("details summary").text }).to eq(
        [ "Initial repair", "Follow-up repair" ]
      )
      expect(rows.first.at_css("details p").text).to eq("Replaced the motor.")
      expect(rows.first.at_css("time")["datetime"]).to eq(oldest_repair_record.created_at.iso8601)
      expect(rows.first.text).to include(
        oldest_repair_record.created_at.strftime("%m/%d/%y %I:%M %p")
      )
      expect(table.at_css("th a")["href"]).to include("repair_records_order=desc")
    end

    it "sorts newest first when the recorded-at header is selected" do
      render partial: "maintenance_tickets/repair_records",
             locals: { ticket: ticket, order: "desc" }
      html = Nokogiri::HTML.fragment(rendered)
      table = html.at_css("table.ticket-repair-history__table")

      expect(table.at_css("th[aria-sort='descending']")).to be_present
      expect(table.css("tbody tr details summary").map(&:text)).to eq(
        [ "Follow-up repair", "Initial repair" ]
      )
      expect(table.at_css("th a")["href"]).to include("repair_records_order=asc")
    end

    it "shows the five latest records and offers to reveal older records" do
      4.times do |index|
        ticket.repair_records.create!(
          technician: technician,
          title: "Earlier repair #{index + 1}",
          description: "Older repair notes.",
          created_at: Time.zone.parse("2026-11-#{11 + index} 09:00")
        )
      end

      render partial: "maintenance_tickets/repair_records",
             locals: { ticket: ticket, order: "asc" }
      html = Nokogiri::HTML.fragment(rendered)
      table = html.at_css("table.ticket-repair-history__table")

      expect(table.css("tbody tr:not([hidden])").map { |row| row.at_css("summary").text }).to eq(
        [ "Earlier repair 2", "Earlier repair 3", "Earlier repair 4", "Initial repair", "Follow-up repair" ]
      )
      expect(table.css("tbody tr[hidden]").map { |row| row.at_css("summary").text })
        .to eq([ "Earlier repair 1" ])
      expect(html.at_css("[data-repair-records-show-all]").text.strip)
        .to eq("Show all repair records")
      expect(html.at_css("[data-repair-records-show-all]")["aria-controls"])
        .to eq("ticket-repair-records")
      expect(html.at_css("[data-repair-records-show-all]")["aria-expanded"])
        .to eq("false")
      expect(table.css("tbody tr[data-repair-record-overflow-row][hidden]").size).to eq(1)
    end

    it "shows edit and delete controls only to the assigned technician" do
      ticket.update!(assigned_technician: technician)
      signed_in_user = technician
      view.define_singleton_method(:current_user) { signed_in_user }

      render partial: "maintenance_tickets/repair_records",
             locals: { ticket: ticket, order: "asc" }
      html = Nokogiri::HTML.fragment(rendered)

      expect(html.css("a.ticket-repair-history__edit").map(&:text)).to eq(%w[Edit Edit])
      expect(html.css("tr[data-repair-editor]")).to be_empty
      expect(html.css("[data-repair-delete-start]").map(&:text))
        .to eq(%w[Delete Delete])
      expect(html.css("[data-repair-delete-confirmation][hidden]").size).to eq(2)
      expect(html.css("[data-repair-delete-confirmation]").map(&:text).join)
        .to include("Delete this repair record?", "Confirm", "Cancel")
      expect(html.css("[data-repair-delete-confirmation] form").size).to eq(2)
      expect(html.css("[data-repair-editing-indicator][hidden]").size).to eq(2)
      expect(html.css(".ticket-repair-history__actions button")).to be_empty
    end

    it "marks the repair row whose details panel is active" do
      ticket.update!(assigned_technician: technician)
      signed_in_user = technician
      view.define_singleton_method(:current_user) { signed_in_user }

      render partial: "maintenance_tickets/repair_records",
             locals: {
               ticket: ticket,
               order: "asc",
               active_repair_panel_id: oldest_repair_record.id
             }
      html = Nokogiri::HTML.fragment(rendered)
      editing_row = html.at_css("tr[data-repair-record-row='#{oldest_repair_record.id}']")
      other_row = html.at_css("tr[data-repair-record-row='#{newest_repair_record.id}']")

      expect(editing_row["aria-current"]).to eq("true")
      expect(editing_row.at_css("[data-repair-editing-indicator]")["hidden"]).to be_nil
      expect(other_row["aria-current"]).to be_nil
      expect(other_row.at_css("[data-repair-editing-indicator]")["hidden"]).to eq("")
    end

    it "hides edit and delete controls after the ticket leaves editable statuses" do
      ticket.update!(
        assigned_technician: technician,
        status: "ready_for_verification"
      )
      signed_in_user = technician
      view.define_singleton_method(:current_user) { signed_in_user }

      render partial: "maintenance_tickets/repair_records",
             locals: { ticket: ticket, order: "asc" }
      html = Nokogiri::HTML.fragment(rendered)

      expect(html.css(".ticket-repair-history__edit, .ticket-repair-history__delete"))
        .to be_empty
    end

    it "renders the Add panel and one hidden Repair Details panel per record" do
      ticket.update!(assigned_technician: technician)
      signed_in_user = technician
      view.define_singleton_method(:current_user) { signed_in_user }
      assign(:maintenance_ticket, ticket)
      assign(:ticket_action_partials, [ "repair_record_form" ])
      assign(:new_repair_record, ticket.repair_records.build)
      assign(:active_repair_panel_id, nil)

      render template: "maintenance_tickets/show"
      html = Nokogiri::HTML.fragment(rendered)

      expect(html.css('[data-repair-panel="add"][hidden]')).to be_empty
      expect(html.css('[data-repair-panel="edit"][hidden]').size).to eq(2)
      expect(html.css("[data-repair-panel-cancel]").size).to eq(2)
      expect(html.css("form[data-repair-add-form]").size).to eq(1)
      expect(
        html.at_css('form[data-repair-add-form] input[name="repair_record[title]"]')["required"]
      ).to eq("required")
      expect(
        html.at_css('form[data-repair-add-form] textarea[name="repair_record[description]"]')["required"]
      ).to be_nil
      expect(html.css(".ticket-show-content > .ticket-details.ticket-panel").size).to eq(1)
      expect(html.css(".ticket-show-content > .ticket-repair-history.ticket-panel").size).to eq(1)
      expect(html.css(".ticket-side-panels > .ticket-panel").map do |panel|
        panel["class"].split.last
      end).to eq(%w[ticket-status-update ticket-repair-panel])
    end

    it "marks repair validation errors to dismiss after five seconds" do
      repair_record = ticket.repair_records.build(technician: technician, title: "")
      repair_record.valid?

      render partial: "maintenance_tickets/repair_record_form",
             locals: { ticket: ticket, repair_record: repair_record }
      alert = Nokogiri::HTML.fragment(rendered).at_css("[role='alert']")

      expect(alert["data-repair-validation-errors"]).to eq("true")
      expect(alert["data-auto-dismiss"]).to eq("5000")
      expect(alert["class"]).to include("ticket-message--error")
      expect(alert.text.strip).to eq("Title can't be blank")
      expect(alert.css("ul, ol, li")).to be_empty
    end

    it "shows repair update confirmation inside the repair panel" do
      ticket.update!(assigned_technician: technician)
      signed_in_user = technician
      view.define_singleton_method(:current_user) { signed_in_user }
      view.define_singleton_method(:flash) do
        { repair_record_update: "Repair record updated." }
      end
      assign(:maintenance_ticket, ticket)
      assign(:ticket_action_partials, [ "repair_record_form" ])
      assign(:new_repair_record, ticket.repair_records.build)
      assign(:active_repair_panel_id, nil)

      render template: "maintenance_tickets/show"
      message = Nokogiri::HTML.fragment(rendered)
        .at_css(".ticket-repair-panel .ticket-message--success")

      expect(message.text.strip).to eq("Repair record updated.")
      expect(message["data-auto-dismiss"]).to eq("5000")
    end
  end

  it "shows status confirmations in the status panel" do
    view.define_singleton_method(:flash) do
      { status_update: "Moved status from Assigned to In progress" }
    end

    render partial: "maintenance_tickets/status_update", locals: { ticket: ticket }
    message = Nokogiri::HTML.fragment(rendered)
      .at_css(".ticket-status-update .ticket-message--success")

    expect(message.text.strip).to eq("Moved status from Assigned to In progress")
    expect(message["data-auto-dismiss"]).to eq("5000")
  end

  it "renders shared details and the controller-selected action partials on the show page" do
    assign(:maintenance_ticket, ticket)
    assign(:ticket_action_partials, %w[priority_update technician_assignment])
    allow(view).to receive(:render).and_call_original

    render template: "maintenance_tickets/show"
    html = Nokogiri::HTML.fragment(rendered)

    expect(view).to have_received(:render).with(
      "maintenance_tickets/priority_update",
      ticket: ticket
    )
    expect(view).to have_received(:render).with(
      "maintenance_tickets/technician_assignment",
      ticket: ticket
    )
    expect(html.at_css("#ticket-details-title").text).to eq("Pump overheats")
    expect(html.at_css("a[href='#{new_maintenance_ticket_path}']").text).to eq("Report Another Problem")
    expect(html.text).to include("The pump stops during operation.", "Jamie Reporter")
  end
end
