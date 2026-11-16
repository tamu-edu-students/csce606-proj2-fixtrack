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
    it "creates a repair record and moves the ticket to in progress without closing it" do
      controller = build_controller(
        user: technician,
        title: "Motor replacement",
        description: "Replaced the motor"
      )

      expect { controller.create }.to change(RepairRecord, :count).by(1)

      repair_record = ticket.repair_records.sole
      expect(repair_record.technician).to eq(technician)
      expect(repair_record.title).to eq("Motor replacement")
      expect(repair_record.description).to eq("Replaced the motor")
      expect(ticket.reload.status).to eq("in_progress")
    end

    it "allows multiple repair records on the same ticket" do
      build_controller(
        user: technician,
        title: "Motor replacement",
        description: "Replaced the motor"
      ).create
      controller = build_controller(
        user: technician,
        title: "Motor test",
        description: "Tested the replacement motor"
      )

      expect { controller.create }.to change { ticket.repair_records.count }.by(1)
      expect(ticket.reload.status).to eq("in_progress")
    end

    it "renders validation errors when the repair title is missing" do
      controller = build_controller(user: technician, title: "", description: "")

      expect(controller).to receive(:render).with(
        "maintenance_tickets/show",
        status: :unprocessable_entity
      )

      controller.create

      repair_record = controller.instance_variable_get(:@repair_record)
      expect(repair_record.errors[:title]).to be_present
      expect(repair_record.errors[:description]).to be_empty
      expect(ticket.reload.status).to eq("assigned")
    end

    it "allows repair notes to be blank" do
      controller = build_controller(
        user: technician,
        title: "Inspection",
        description: ""
      )

      expect { controller.create }.to change(RepairRecord, :count).by(1)
      expect(ticket.repair_records.sole.description).to be_blank
    end

    it "does not allow another technician to create a record on the ticket" do
      controller = build_controller(
        user: other_technician,
        title: "Motor replacement",
        description: "Replaced the motor"
      )

      expect { controller.create }.to raise_error(ActiveRecord::RecordNotFound)
      expect(ticket.repair_records).to be_empty
    end

    it "does not allow non-technicians to create repair records" do
      controller = build_controller(
        user: reporter,
        title: "Motor replacement",
        description: "Replaced the motor"
      )

      controller.create

      expect(controller.response).to be_redirect
      expect(controller.flash[:alert]).to eq(
        "Only technicians can add repair records."
      )
      expect(ticket.repair_records).to be_empty
    end
  end

  describe "#destroy" do
    let(:repair_record) do
      ticket.repair_records.create!(
        technician: technician,
        title: "Motor replacement",
        description: "Replaced the motor"
      )
    end

    it "allows the assigned technician to delete a repair record" do
      controller = build_controller(
        user: technician,
        title: "",
        description: "",
        record_id: repair_record.id
      )

      expect { controller.destroy }.to change(RepairRecord, :count).by(-1)
      expect(controller.response).to be_redirect
    end

    it "does not allow another technician to delete the repair record" do
      controller = build_controller(
        user: other_technician,
        title: "",
        description: "",
        record_id: repair_record.id
      )

      expect { controller.destroy }.to raise_error(ActiveRecord::RecordNotFound)
      expect(repair_record).to be_persisted
    end

    it "does not allow non-technicians to delete repair records" do
      controller = build_controller(
        user: reporter,
        title: "",
        description: "",
        record_id: repair_record.id
      )

      controller.destroy

      expect(controller.response).to be_redirect
      expect(controller.flash[:alert]).to eq(
        "Only the assigned technician can manage repair records."
      )
      expect(repair_record).to be_persisted
    end

    %w[ready_for_verification closed].each do |status|
      it "does not allow deleting a repair record when the ticket is #{status}" do
        ticket.update!(status: status)
        controller = build_controller(
          user: technician,
          title: "",
          description: "",
          record_id: repair_record.id
        )

        controller.destroy

        expect(controller.response).to be_redirect
        expect(repair_record).to be_persisted
      end
    end
  end

  describe "#update" do
    let(:repair_record) do
      ticket.repair_records.create!(
        technician: technician,
        title: "Motor replacement",
        description: "Replaced the motor"
      )
    end

    it "allows the assigned technician to edit the title and notes" do
      controller = build_controller(
        user: technician,
        title: "Motor rebuilt",
        description: "Rebuilt and tested the motor",
        record_id: repair_record.id
      )

      controller.update

      expect(repair_record.reload.title).to eq("Motor rebuilt")
      expect(repair_record.description).to eq("Rebuilt and tested the motor")
      expect(controller.response).to be_redirect
    end

    it "loads the fallback edit page for the assigned technician" do
      controller = build_controller(
        user: technician,
        title: "",
        description: "",
        record_id: repair_record.id
      )

      controller.edit

      expect(controller.instance_variable_get(:@repair_record)).to eq(repair_record)
    end

    it "does not allow another technician to edit the repair record" do
      controller = build_controller(
        user: other_technician,
        title: "Unauthorized edit",
        description: "Changed notes",
        record_id: repair_record.id
      )

      expect { controller.update }.to raise_error(ActiveRecord::RecordNotFound)
      expect(repair_record.reload.title).to eq("Motor replacement")
    end

    it "does not allow editing when the ticket is ready for verification" do
      ticket.update!(status: "ready_for_verification")
      controller = build_controller(
        user: technician,
        title: "Unauthorized edit",
        description: "Changed notes",
        record_id: repair_record.id
      )

      controller.update

      expect(controller.response).to be_redirect
      expect(repair_record.reload.title).to eq("Motor replacement")
    end

    it "keeps validation errors in the repair details panel when invalid changes are submitted" do
      controller = build_controller(
        user: technician,
        title: "   ",
        description: "",
        record_id: repair_record.id,
        panel_edit: true
      )

      expect(controller).to receive(:render).with(
        "maintenance_tickets/show",
        status: :unprocessable_entity
      )

      controller.update

      expect(controller.instance_variable_get(:@active_repair_panel_id))
        .to eq(repair_record.id)
      expect(controller.instance_variable_get(:@repair_record).errors[:title]).to be_present
      expect(controller.instance_variable_get(:@repair_record).errors).not_to be_empty
      expect(controller.instance_variable_get(:@new_repair_record)).to be_new_record
    end

    it "renders the fallback edit page when invalid changes are submitted without JavaScript" do
      controller = build_controller(
        user: technician,
        title: "",
        description: "",
        record_id: repair_record.id
      )

      expect(controller).to receive(:render).with(
        :edit,
        status: :unprocessable_entity
      )

      controller.update

      expect(controller.instance_variable_get(:@repair_record).errors).not_to be_empty
    end
  end

  def build_controller(user:, title:, description:, record_id: nil, panel_edit: false)
    controller = described_class.new
    controller.instance_variable_set(:@current_user_for_test, user)
    controller.define_singleton_method(:current_user) { @current_user_for_test }
    controller.set_request!(ActionDispatch::TestRequest.create)
    controller.set_response!(ActionDispatch::TestResponse.new)

    ticket_id = ticket.id
    parameters = {
      maintenance_ticket_id: ticket_id,
      repair_record: {
        title: title,
        description: description
      }
    }
    parameters[:id] = record_id if record_id
    parameters[:panel_edit] = "true" if panel_edit
    controller.define_singleton_method(:params) do
      ActionController::Parameters.new(parameters)
    end
    controller
  end
end
