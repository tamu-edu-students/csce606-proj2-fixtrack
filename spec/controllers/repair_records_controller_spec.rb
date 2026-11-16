require "rails_helper"

RSpec.describe RepairRecordsController do
  let(:technician) do
    User.create!(
      name: "Technician",
      email: "technician@example.com",
      password: "password",
      role: "technician"
    )
  end
  let(:other_technician) do
    User.create!(
      name: "Other Technician",
      email: "other-technician@example.com",
      password: "password",
      role: "technician"
    )
  end
  let(:reporter) do
    User.create!(
      name: "Reporter",
      email: "reporter@example.com",
      password: "password",
      role: "reporter"
    )
  end
  let(:equipment) do
    Equipment.create!(
      name: "Pump",
      asset_identifier: "PUMP-1",
      location: "Building A",
      status: "Available"
    )
  end
  let(:ticket) do
    MaintenanceTicket.create!(
      title: "Pump failure",
      description: "The pump will not start",
      priority: "high",
      status: "assigned",
      equipment: equipment,
      reporter: reporter,
      assigned_technician: technician
    )
  end

  describe "#create" do
    it "creates a repair record for the assigned technician without resolving the ticket" do
      controller = build_controller(user: technician, description: "Replaced the motor")

      expect { controller.create }.to change(RepairRecord, :count).by(1)

      repair_record = ticket.repair_records.sole
      expect(repair_record.technician).to eq(technician)
      expect(repair_record.description).to eq("Replaced the motor")
      expect(repair_record.completed_at).to eq(Time.zone.parse("2026-11-15 10:30"))
      expect(ticket.reload.status).to eq("assigned")
    end

    it "allows multiple repair records on the same ticket" do
      build_controller(user: technician, description: "Replaced the motor").create
      controller = build_controller(user: technician, description: "Tested the replacement motor")

      expect { controller.create }.to change { ticket.repair_records.count }.by(1)
    end

    it "renders the ticket with validation errors when required fields are missing" do
      controller = build_controller(user: technician, description: "", completed_at: "")

      expect(controller).to receive(:render).with(
        "maintenance_tickets/show",
        status: :unprocessable_entity
      )

      controller.create

      repair_record = controller.instance_variable_get(:@repair_record)
      expect(repair_record.errors[:description]).to be_present
      expect(repair_record.errors[:completed_at]).to be_present
    end

    it "does not allow another technician to create a record on the ticket" do
      controller = build_controller(user: other_technician, description: "Replaced the motor")

      expect { controller.create }.to raise_error(ActiveRecord::RecordNotFound)
      expect(ticket.repair_records).to be_empty
    end

    it "does not allow non-technicians to create repair records" do
      controller = build_controller(user: reporter, description: "Replaced the motor")

      controller.create

      expect(controller.response).to be_redirect
      expect(controller.flash[:alert]).to eq(
        "Only technicians can add repair records."
      )
      expect(ticket.repair_records).to be_empty
    end
  end

  def build_controller(user:, description:, completed_at: "2026-11-15 10:30")
    controller = described_class.new
    controller.instance_variable_set(:@current_user_for_test, user)
    controller.define_singleton_method(:current_user) { @current_user_for_test }
    controller.set_request!(ActionDispatch::TestRequest.create)
    controller.set_response!(ActionDispatch::TestResponse.new)

    ticket_id = ticket.id
    controller.define_singleton_method(:params) do
      ActionController::Parameters.new(
        maintenance_ticket_id: ticket_id,
        repair_record: {
          description: description,
          completed_at: completed_at
        }
      )
    end
    controller
  end
end
