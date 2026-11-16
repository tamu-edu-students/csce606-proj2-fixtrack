require "spec_helper"
require_relative "../../app/policies/maintenance_ticket_policy"

RSpec.describe MaintenanceTicketPolicy do
  subject(:policy) { described_class.new(user, ticket) }

  let(:ticket) { Object.new }
  let(:user) { Struct.new(:role).new(role) }

  describe "#update_priority?" do
    %w[manager admin].each do |allowed_role|
      context "with a #{allowed_role}" do
        let(:role) { allowed_role }

        it "allows priority updates" do
          expect(policy.update_priority?).to be true
        end
      end
    end

    [ "technician", "reporter", "unknown", nil ].each do |denied_role|
      context "with role #{denied_role.inspect}" do
        let(:role) { denied_role }

        it "denies priority updates" do
          expect(policy.update_priority?).to be false
        end
      end
    end

    context "without a signed-in user" do
      let(:user) { nil }

      it "denies priority updates" do
        expect(policy.update_priority?).to be false
      end
    end
  end
end
