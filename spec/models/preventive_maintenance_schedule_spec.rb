require "rails_helper"

RSpec.describe PreventiveMaintenanceSchedule, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:equipment) { Equipment.create!(name: "Pump", asset_identifier: "PM-013", location: "Lab", status: "Available") }
  let(:attributes) { { equipment: equipment, task: "Inspect bearings", due_date: Date.tomorrow } }

  around do |example|
    travel_to(Time.zone.local(2026, 11, 20, 12)) { example.run }
  end

  it "persists a task and future date for existing equipment" do
    schedule = described_class.create!(attributes.merge(task: "  Inspect bearings  "))
    expect(schedule.reload).to have_attributes(task: "Inspect bearings", due_date: Date.tomorrow, equipment_id: equipment.id)
  end

  [ nil, "", "   " ].each do |task|
    it "rejects a blank task #{task.inspect}" do
      schedule = described_class.new(attributes.merge(task: task))
      expect(schedule).not_to be_valid
      expect(schedule.errors[:task]).to be_present
    end
  end

  [ nil, "not-a-date" ].each do |date|
    it "rejects a missing or invalid date #{date.inspect}" do
      schedule = described_class.new(attributes.merge(due_date: date))
      expect(schedule).not_to be_valid
      expect(schedule.errors[:due_date]).to be_present
    end
  end

  it "rejects today's date" do
    schedule = described_class.new(attributes.merge(due_date: Date.current))
    expect(schedule).not_to be_valid
    expect(schedule.errors[:due_date]).to include("must be after today")
  end

  it "rejects a past date" do
    expect(described_class.new(attributes.merge(due_date: Date.yesterday))).not_to be_valid
  end

  it "requires existing equipment" do
    schedule = described_class.new(attributes.merge(equipment: nil))
    expect(schedule).not_to be_valid
    expect(schedule.errors[:equipment]).to be_present
  end

  it "keeps a saved schedule valid when its due date passes" do
    schedule = described_class.create!(attributes)
    travel 3.days
    expect(schedule.reload).to be_valid
  end

  it "protects scheduled work when removal of equipment is attempted" do
    schedule = described_class.create!(attributes)
    expect(equipment.destroy).to be(false)
    expect(equipment.errors[:base]).to be_present
    expect(schedule.reload.equipment_id).to eq(equipment.id)
  end
end
