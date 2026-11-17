require "rails_helper"

RSpec.describe MaintenanceTicket, type: :model do
  let(:reporter) { assignment_user("reporter", "reporter") }
  let(:technician) { assignment_user("technician", "original") }
  let(:replacement) { assignment_user("technician", "replacement") }
  let(:equipment) do
    Equipment.create!(name: "Pump", asset_identifier: "ASSIGNMENT-OPERATIONS-1",
                      location: "Building A", status: "Available")
  end
  let(:ticket) do
    described_class.create!(title: "Pump failure", description: "The pump will not start.",
                            priority: "high", status: "submitted",
                            equipment: equipment, reporter: reporter)
  end

  def assignment_user(role, identifier)
    User.create!(name: identifier.humanize, email: "assignment-#{identifier}@example.com",
                 password: "password123", role: role)
  end

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

  describe "#assignment_allowed?" do
    %w[submitted assigned in_progress].each do |status|
      it "allows assignment changes in #{status}" do
        ticket.status = status

        expect(ticket.assignment_allowed?).to be true
      end
    end

    %w[rejected ready_for_verification closed].each do |status|
      it "disallows assignment changes in #{status}" do
        ticket.status = status

        expect(ticket.assignment_allowed?).to be false
      end
    end
  end

  describe "#update_assignment" do
    it "persists the initial technician and assigned status together" do
      original_attributes = ticket.attributes.except("assigned_technician_id", "status", "updated_at")

      expect(ticket.update_assignment(technician.id.to_s)).to be true
      expect(ticket.reload.assigned_technician).to eq(technician)
      expect(ticket.status).to eq("assigned")
      expect(ticket.attributes.except("assigned_technician_id", "status", "updated_at"))
        .to eq(original_attributes)
    end

    %w[assigned in_progress].each do |status|
      it "reassigns #{status} tickets without changing status or repair history" do
        ticket.update!(status: status, assigned_technician: technician)
        repair = ticket.repair_records.create!(technician: technician, title: "Inspection",
                                              description: "Checked the pump.")
        original_repair = repair.attributes
        original_attributes = ticket.attributes.except("assigned_technician_id", "updated_at")

        expect(ticket.update_assignment(replacement.id)).to be true
        expect(ticket.reload.assigned_technician).to eq(replacement)
        expect(ticket.attributes.except("assigned_technician_id", "updated_at"))
          .to eq(original_attributes)
        expect(ticket.repair_records.count).to eq(1)
        expect(repair.reload.attributes).to eq(original_repair)
      end

      it "accepts the current technician again on a #{status} ticket" do
        ticket.update!(status: status, assigned_technician: technician)

        expect(ticket.update_assignment(technician.id)).to be true
        expect(ticket.reload.assigned_technician).to eq(technician)
        expect(ticket.status).to eq(status)
      end
    end

    [ nil, "" ].each do |blank|
      it "clears an assigned ticket using #{blank.inspect} and returns it to submitted" do
        ticket.update!(status: "assigned", assigned_technician: technician)

        expect(ticket.update_assignment(blank)).to be true
        expect(ticket.reload.assigned_technician).to be_nil
        expect(ticket.status).to eq("submitted")
      end
    end

    %w[submitted assigned in_progress].each do |status|
      it "preserves #{status} when clearing a ticket with repair records" do
        ticket.update!(status: status, assigned_technician: technician)
        repair = ticket.repair_records.create!(technician: technician, title: "Inspection",
                                              description: "Checked the pump.")
        original_repair = repair.attributes

        expect(ticket.update_assignment(nil)).to be true
        expect(ticket.reload.assigned_technician).to be_nil
        expect(ticket.status).to eq(status)
        expect(ticket.repair_records.count).to eq(1)
        expect(repair.reload.attributes).to eq(original_repair)
      end
    end

    %w[submitted in_progress].each do |status|
      it "preserves #{status} when clearing without repair records" do
        ticket.update!(status: status, assigned_technician: technician)

        expect(ticket.update_assignment(nil)).to be true
        expect(ticket.reload.assigned_technician).to be_nil
        expect(ticket.status).to eq(status)
      end
    end

    it "accepts an already-unassigned submitted ticket" do
      expect(ticket.update_assignment(nil)).to be true
      expect(ticket.reload.assigned_technician).to be_nil
      expect(ticket.status).to eq("submitted")
    end

    %w[rejected ready_for_verification closed].each do |status|
      [ :assign, :reassign, :clear ].each do |operation|
        it "rejects #{operation} in #{status} without changing persisted data" do
          ticket.update!(status: status,
                         assigned_technician: (technician unless operation == :assign))
          original_attributes = ticket.attributes
          assignee_id = operation == :clear ? nil : replacement.id

          expect(ticket.update_assignment(assignee_id)).to be false
          expect(ticket.errors[:status]).to include("does not allow technician assignment changes")
          expect(ticket.reload.attributes).to eq(original_attributes)
        end
      end
    end

    [ :unassigned, :assigned ].each do |initial_assignment|
      it "rejects invalid assignees atomically when initially #{initial_assignment}" do
        if initial_assignment == :assigned
          ticket.update!(status: "assigned", assigned_technician: technician)
        end
        original_attributes = ticket.attributes
        malformed_id = "#{technician.id}oops"
        missing_id = User.maximum(:id) + 1

        # Include values Rails would otherwise silently coerce into clearing or an ID.
        [ reporter.id, missing_id, "invalid", malformed_id, " ", 0, -1, [], {} ].each do |id|
          expect(ticket.update_assignment(id)).to be false
          expect(ticket.errors[:assigned_technician]).to include("must be an existing technician")
          expect(ticket.reload.attributes).to eq(original_attributes)
        end
      end
    end

    it "does not persist assignment or status when another validation fails" do
      original_attributes = ticket.attributes
      ticket.title = ""

      expect(ticket.update_assignment(technician.id)).to be false
      expect(ticket.errors[:title]).to include("can't be blank")
      expect(ticket.reload.attributes).to eq(original_attributes)
    end
  end
end
