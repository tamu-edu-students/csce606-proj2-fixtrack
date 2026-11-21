require "rails_helper"

RSpec.describe PreventiveMaintenanceSchedulePolicy do
  [ "manager", "technician", "reporter", nil ].each do |role|
    it "enforces scheduling and reading permissions for #{role || 'anonymous'} users" do
      user = role && User.new(role: role)
      policy = described_class.new(user, PreventiveMaintenanceSchedule)
      expect(policy.create?).to eq(role == "manager")
      expect(policy.new?).to eq(role == "manager")
      expect(policy.index?).to eq(!role.nil?)
    end
  end
end
