require "rails_helper"

RSpec.describe MaintenanceTicketsController do
  let(:technician) do
    User.create!(name: "Technician", email: "technician@example.com", password: "password", role: "technician")
  end
  let(:other_technician) do
    User.create!(name: "Other Technician", email: "other-technician@example.com", password: "password", role: "technician")
  end
  let(:reporter) do
    User.create!(name: "Reporter", email: "reporter@example.com", password: "password", role: "reporter")
  end
  let(:equipment) do
    Equipment.create!(
      name: "Pump",
      asset_identifier: "PUMP-1",
      location: "Building A",
      status: "Available"
    )
  end
  let(:assigned_ticket) { create_ticket("Assigned ticket", technician, status: "assigned") }
  let(:in_progress_ticket) { create_ticket("In-progress ticket", technician, status: "in_progress") }
  let(:open_ticket) { create_ticket("Open ticket", technician, status: "open") }
  let(:resolved_ticket) { create_ticket("Resolved ticket", technician, status: "resolved") }
  let(:other_technician_ticket) { create_ticket("Other technician ticket", other_technician, status: "assigned") }
  let(:self_reported_ticket) do
    create_ticket("Self-reported ticket", nil, status: "open", reporter_user: technician)
  end
  let(:maintenance_tickets_controller) { described_class.new }

  before do
    signed_in_user = technician
    maintenance_tickets_controller.define_singleton_method(:current_user) { signed_in_user }
  end

  describe "#index" do
    it "lists only assigned and in-progress tickets assigned to the signed-in technician" do
      assigned_ticket
      in_progress_ticket
      open_ticket
      resolved_ticket
      other_technician_ticket
      self_reported_ticket

      maintenance_tickets_controller.index

      expect(maintenance_tickets_controller.instance_variable_get(:@maintenance_tickets))
        .to contain_exactly(assigned_ticket, in_progress_ticket)
    end
  end

  describe "#show" do
    it "allows the technician to open an assigned ticket" do
      ticket = assigned_ticket
      maintenance_tickets_controller.define_singleton_method(:params) do
        ActionController::Parameters.new(id: ticket.id)
      end

      maintenance_tickets_controller.show

      expect(maintenance_tickets_controller.instance_variable_get(:@maintenance_ticket)).to eq(ticket)
      expect(maintenance_tickets_controller.instance_variable_get(:@ticket_action_partials))
        .to eq(%w[repair_record_form])
    end

    it "assigns manager-only action partials to managers" do
      ticket = assigned_ticket
      manager = User.create!(
        name: "Manager",
        email: "manager@example.com",
        password: "password",
        role: "manager"
      )
      maintenance_tickets_controller.define_singleton_method(:current_user) { manager }
      maintenance_tickets_controller.define_singleton_method(:params) do
        ActionController::Parameters.new(id: ticket.id)
      end

      maintenance_tickets_controller.show

      expect(maintenance_tickets_controller.instance_variable_get(:@ticket_action_partials))
        .to eq(%w[priority_update technician_assignment])
    end

    it "does not assign role-specific action partials to reporters" do
      ticket = create_ticket("Reported ticket", nil, status: "open", reporter_user: reporter)
      signed_in_reporter = reporter
      maintenance_tickets_controller.define_singleton_method(:current_user) { signed_in_reporter }
      maintenance_tickets_controller.define_singleton_method(:params) do
        ActionController::Parameters.new(id: ticket.id)
      end

      maintenance_tickets_controller.show

      expect(maintenance_tickets_controller.instance_variable_get(:@ticket_action_partials)).to be_empty
    end

    it "allows the technician to open an in-progress ticket" do
      ticket = in_progress_ticket
      maintenance_tickets_controller.define_singleton_method(:params) do
        ActionController::Parameters.new(id: ticket.id)
      end

      maintenance_tickets_controller.show

      expect(maintenance_tickets_controller.instance_variable_get(:@maintenance_ticket)).to eq(ticket)
    end

    it "allows the technician to open a ticket they reported even if it is unassigned" do
      ticket = self_reported_ticket
      maintenance_tickets_controller.define_singleton_method(:params) do
        ActionController::Parameters.new(id: ticket.id)
      end

      maintenance_tickets_controller.show

      expect(maintenance_tickets_controller.instance_variable_get(:@maintenance_ticket)).to eq(ticket)
    end

    it "does not allow the technician to open another technician's ticket" do
      ticket = other_technician_ticket
      maintenance_tickets_controller.define_singleton_method(:params) do
        ActionController::Parameters.new(id: ticket.id)
      end

      expect { maintenance_tickets_controller.show }.to raise_error(ActiveRecord::RecordNotFound)
    end

    %w[open resolved].each do |status|
      it "does not allow the technician to open an assigned #{status} ticket" do
        ticket = create_ticket("#{status.humanize} ticket", technician, status: status)
        maintenance_tickets_controller.define_singleton_method(:params) do
          ActionController::Parameters.new(id: ticket.id)
        end

        expect { maintenance_tickets_controller.show }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#create" do
    it "redirects technicians to the ticket they submitted" do
      ticket = instance_double(MaintenanceTicket, reporter: nil, save: true)
      equipment_id = equipment.id
      maintenance_tickets_controller.define_singleton_method(:params) do
        ActionController::Parameters.new(
          maintenance_ticket: {
            title: "New issue",
            description: "Needs repair",
            priority: "medium",
            equipment_id: equipment_id
          }
        )
      end
      allow(MaintenanceTicket).to receive(:new).and_return(ticket)

      expect(ticket).to receive(:reporter=).with(technician)
      expect(maintenance_tickets_controller).to receive(:redirect_to).with(
        ticket,
        notice: "Maintenance ticket created successfully."
      )

      maintenance_tickets_controller.create
    end
  end

  def create_ticket(title, assigned_technician, status:, reporter_user: reporter)
    MaintenanceTicket.create!(
      title: title,
      description: "Repair required",
      priority: "medium",
      status: status,
      equipment: equipment,
      reporter: reporter_user,
      assigned_technician: assigned_technician
    )
  end
end
