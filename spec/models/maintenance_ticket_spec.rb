
require "rails_helper"

RSpec.describe MaintenanceTicket, type: :model do
  describe "technician assignment eligibility" do
    let(:reporter) { create_assignment_user("reporter") }
    let(:technician) { create_assignment_user("technician") }
    let(:equipment) do
      Equipment.create!(name: "Pump", asset_identifier: "ASSIGNMENT-1",
                        location: "Building A", status: "Available")
    end
    let(:ticket) do
      described_class.new(title: "Pump failure", description: "The pump will not start.",
                          priority: "medium", status: "submitted",
                          equipment: equipment, reporter: reporter)
    end

    def create_assignment_user(role)
      User.create!(name: role.humanize, email: "assignment-#{role}@example.com",
                   password: "password123", role: role)
    end

    it "persists an unassigned ticket" do
      expect(ticket.save).to be true
      expect(ticket.reload.assigned_technician).to be_nil
    end

    it "persists an existing technician without a company" do
      expect(technician.company).to be_nil
      ticket.assigned_technician = technician

      expect(ticket.save).to be true
      expect(ticket.reload.assigned_technician).to eq(technician)
      expect(ticket.status).to eq("submitted")
    end

    it "allows a technician from a different company" do
      reporter.update!(company: Company.create!(name: "Reporting company"))
      technician.update!(company: Company.create!(name: "Service company"))
      ticket.assigned_technician = technician

      expect(ticket.save).to be true
      expect(ticket.reload.assigned_technician).to eq(technician)
    end

    [ "manager", "reporter", "admin" ].each do |role|
      it "rejects a #{role} as the initial assignee" do
        assignee = role == "reporter" ? reporter : create_assignment_user("manager")
        # Admin is authorized elsewhere but is not a provisionable role in this model.
        assignee.update_column(:role, role) if role == "admin"
        ticket.save!
        original_attributes = ticket.attributes

        expect(ticket.update(assigned_technician_id: assignee.id)).to be false
        expect(ticket.errors[:assigned_technician]).to include("must be an existing technician")
        expect(ticket.reload.attributes).to eq(original_attributes)
        expect(ticket.assigned_technician).to be_nil
      end
    end

    it "rejects a nonexistent initial assignee without changing persisted data" do
      ticket.save!
      original_attributes = ticket.attributes
      nonexistent_id = User.maximum(:id) + 1

      expect(ticket.update(assigned_technician_id: nonexistent_id)).to be false
      expect(ticket.errors[:assigned_technician]).to include("must be an existing technician")
      expect(ticket.reload.attributes).to eq(original_attributes)
      expect(ticket.assigned_technician).to be_nil
    end

    it "preserves the previous technician after invalid reassignments" do
      ticket.assigned_technician = technician
      ticket.save!
      original_attributes = ticket.attributes

      [ reporter.id, User.maximum(:id) + 1 ].each do |invalid_id|
        expect(ticket.update(assigned_technician_id: invalid_id)).to be false
        expect(ticket.errors[:assigned_technician]).to include("must be an existing technician")
        expect(ticket.reload.attributes).to eq(original_attributes)
        expect(ticket.assigned_technician).to eq(technician)
      end
    end

    it "allows clearing the optional association" do
      ticket.assigned_technician = technician
      ticket.save!

      expect(ticket.update(assigned_technician_id: nil)).to be true
      expect(ticket.reload.assigned_technician).to be_nil
    end
  end

  describe "field validations" do
    def field_errors(ticket, field)
      ticket.errors.clear

      described_class.validators_on(field).each do |validator|
        validator.validate(ticket)
      end

      ticket.errors[field]
    end

    it "rejects a missing title" do
      ticket = described_class.new(title: nil)

      expect(field_errors(ticket, :title)).to include("can't be blank")
    end

    it "rejects a whitespace-only title" do
      ticket = described_class.new(title: "   ")

      expect(field_errors(ticket, :title)).to include("can't be blank")
    end

    it "rejects a missing description" do
      ticket = described_class.new(description: nil)

      expect(field_errors(ticket, :description)).to include("can't be blank")
    end

    it "rejects a whitespace-only description" do
      ticket = described_class.new(description: "   ")

      expect(field_errors(ticket, :description)).to include("can't be blank")
    end

    it "rejects a missing priority" do
      ticket = described_class.new(priority: nil)

      expect(field_errors(ticket, :priority)).to include("can't be blank")
    end

    it "rejects an unsupported priority" do
      ticket = described_class.new(priority: "critical")

      expect(field_errors(ticket, :priority)).to include(
        "is not included in the list"
      )
    end

    it "accepts supported priorities" do
      %w[low medium high].each do |priority|
        ticket = described_class.new(priority: priority)

        expect(field_errors(ticket, :priority)).to be_empty
      end
    end

    it "rejects an unsupported status" do
      %w[cancelled open resolved].each do |status|
        ticket = described_class.new(status: status)

        expect(field_errors(ticket, :status)).to include("is not included in the list")
      end
    end

    it "accepts supported statuses" do
      described_class::STATUSES.each do |status|
        ticket = described_class.new(status: status)

        expect(field_errors(ticket, :status)).to be_empty
      end
    end
  end

  describe "equipment reference validation" do
    let(:ticket) do
      described_class.new(
        title: "Motor failure",
        description: "Motor does not start",
        priority: "high",
        equipment_id: 999_999
      )
    end

    before do
      equipment_model = Class.new
      equipment_model.define_singleton_method(:exists?) { |**_options| false }
      stub_const("Equipment", equipment_model)
    end

    it "rejects an equipment ID that does not exist" do
      allow(Equipment).to receive(:exists?)
        .with(id: 999_999)
        .and_return(false)

      ticket.send(:equipment_id_must_reference_existing_equipment)

      expect(ticket.errors[:equipment_id]).to include(
        "must reference existing equipment"
      )
    end

    it "does not reject an existing equipment ID" do
      allow(Equipment).to receive(:exists?)
        .with(id: 999_999)
        .and_return(true)

      ticket.send(:equipment_id_must_reference_existing_equipment)

      expect(ticket.errors[:equipment_id]).to be_empty
    end
  end
end
