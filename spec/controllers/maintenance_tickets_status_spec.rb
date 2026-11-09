require "rails_helper"

RSpec.describe MaintenanceTicketsController do
  subject(:controller) { described_class.new }

  let(:manager) { Struct.new(:id, :role).new(1, "manager") }
  let(:technician) { Struct.new(:id, :role).new(2, "technician") }
  let(:reporter) { Struct.new(:id, :role).new(3, "reporter") }
  let(:ticket) do
    Struct.new(:assigned_technician_id, :reporter_id).new(technician.id, reporter.id)
  end

  it "allows managers to submit, reject, or assign tickets" do
    expect(controller.status_options_for(manager, ticket))
      .to eq(%w[submitted rejected assigned])
  end

  it "allows the manager who reported the ticket to close it" do
    ticket.reporter_id = manager.id

    expect(controller.status_options_for(manager, ticket))
      .to eq(%w[submitted rejected assigned closed])
  end

  it "does not allow a manager who did not report the ticket to close it" do
    expect(controller.status_options_for(manager, ticket)).not_to include("closed")
  end

  it "allows assigned technicians to set assigned, in-progress, or ready-for-verification" do
    expect(controller.status_options_for(technician, ticket))
      .to eq(%w[assigned in_progress ready_for_verification])
  end

  it "also allows an assigned technician who created the ticket to close it" do
    ticket.reporter_id = technician.id

    expect(controller.status_options_for(technician, ticket))
      .to eq(%w[assigned in_progress ready_for_verification closed])
  end

  it "allows a technician creator to close their ticket even when not assigned" do
    ticket.assigned_technician_id = nil
    ticket.reporter_id = technician.id

    expect(controller.status_options_for(technician, ticket)).to eq(["closed"])
  end

  it "does not allow a technician who did not create the ticket to update it when unassigned" do
    ticket.assigned_technician_id = nil

    expect(controller.status_options_for(technician, ticket)).to be_empty
  end

  it "allows the reporter who created the ticket to close it" do
    expect(controller.status_options_for(reporter, ticket)).to eq(["closed"])
  end

  it "does not allow a reporter who did not create the ticket to change its status" do
    ticket.reporter_id = 4

    expect(controller.status_options_for(reporter, ticket)).to be_empty
  end
end
