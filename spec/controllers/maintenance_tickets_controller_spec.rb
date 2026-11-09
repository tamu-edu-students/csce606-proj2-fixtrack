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
    end

    it "allows the technician to open an in-progress ticket" do
      ticket = in_progress_ticket
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

  def create_ticket(title, assigned_technician, status:)
    MaintenanceTicket.create!(
      title: title,
      description: "Repair required",
      priority: "medium",
      status: status,
      equipment: equipment,
      reporter: reporter,
      assigned_technician: assigned_technician
    )
  end
end
