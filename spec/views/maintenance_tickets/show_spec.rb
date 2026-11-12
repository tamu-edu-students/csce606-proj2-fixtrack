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
    view.define_singleton_method(:status_options_for) { |_user, _ticket| [] }
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

  it "renders shared details and the controller-selected action partials on the show page" do
    assign(:maintenance_ticket, ticket)
    assign(:ticket_action_partials, %w[priority_update technician_assignment])
    allow(view).to receive(:render).and_call_original

    render template: "maintenance_tickets/show"
    html = Nokogiri::HTML.fragment(rendered)

    expect(view).to have_received(:render).with("priority_update", ticket: ticket)
    expect(view).to have_received(:render).with("technician_assignment", ticket: ticket)
    expect(html.at_css("#ticket-details-title").text).to eq("Pump overheats")
    expect(html.at_css("a[href='#{new_maintenance_ticket_path}']").text).to eq("Report Another Problem")
    expect(html.text).to include("The pump stops during operation.", "Jamie Reporter")
  end
end
