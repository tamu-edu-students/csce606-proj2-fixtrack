
require "rails_helper"

RSpec.describe MaintenanceTicket, type: :model do
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
