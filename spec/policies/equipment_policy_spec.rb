require "spec_helper"
require_relative "../../app/policies/equipment_policy"

RSpec.describe EquipmentPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { double("equipment") }
  let(:user) { Struct.new(:role) { def manager? = role == "manager" }.new(role) }

  describe "read access" do
    [ "manager", "technician", "reporter" ].each do |role_name|
      context "with a #{role_name}" do
        let(:role) { role_name }

        it "allows viewing equipment" do
          expect(policy.index?).to be true
          expect(policy.show?).to be true
        end
      end
    end

    context "without a user" do
      let(:user) { nil }

      it "denies viewing equipment" do
        expect(policy.index?).to be false
        expect(policy.show?).to be false
      end
    end
  end

  describe "write access" do
    context "with a manager" do
      let(:role) { "manager" }

      it "allows managing equipment" do
        expect(policy.create?).to be true
        expect(policy.update?).to be true
        expect(policy.destroy?).to be true
      end
    end

    [ "technician", "reporter" ].each do |role_name|
      context "with a #{role_name}" do
        let(:role) { role_name }

        it "denies managing equipment" do
          expect(policy.create?).to be false
          expect(policy.update?).to be false
          expect(policy.destroy?).to be false
        end
      end
    end
  end
end
