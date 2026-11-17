require "rails_helper"

RSpec.describe MaintenanceTicketsController do
  subject(:controller) { described_class.new }

  let(:manager) { Struct.new(:id, :role).new(1, "manager") }
  let(:technician) { Struct.new(:id, :role).new(2, "technician") }
  let(:reporter) { Struct.new(:id, :role).new(3, "reporter") }
  let(:repair_records) { double(exists?: false) }
  let(:ticket) do
    ticket_class = Struct.new(
      :id,
      :assigned_technician_id,
      :reporter_id,
      :status,
      :repair_records
    ) do
      def update(**_attributes)
        true
      end
    end
    ticket_class.new(12, technician.id, reporter.id, "assigned", repair_records)
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

  it "does not offer status edits for closed tickets to any role" do
    ticket.status = "closed"
    ticket.reporter_id = reporter.id

    [ manager, technician, reporter ].each do |user|
      expect(controller.status_options_for(user, ticket)).to be_empty
    end
  end

  it "allows assigned technicians to set assigned, in-progress, or ready-for-verification" do
    expect(controller.status_options_for(technician, ticket))
      .to eq(%w[assigned in_progress ready_for_verification])
  end

  it "does not offer statuses below in progress when repair records exist" do
    allow(repair_records).to receive(:exists?).and_return(true)

    expect(controller.status_options_for(technician, ticket))
      .to eq(%w[in_progress ready_for_verification])
  end

  it "does not allow managers to return tickets with repairs to a pre-progress status" do
    allow(repair_records).to receive(:exists?).and_return(true)

    expect(controller.status_options_for(manager, ticket)).to be_empty
  end

  it "also allows an assigned technician who created the ticket to close it" do
    ticket.reporter_id = technician.id

    expect(controller.status_options_for(technician, ticket))
      .to eq(%w[assigned in_progress ready_for_verification closed])
  end

  it "does not allow an unassigned technician to update a ticket they reported" do
    ticket.assigned_technician_id = nil
    ticket.reporter_id = technician.id

    expect(controller.status_options_for(technician, ticket)).to be_empty
  end

  it "does not allow a technician who did not create the ticket to update it when unassigned" do
    ticket.assigned_technician_id = nil

    expect(controller.status_options_for(technician, ticket)).to be_empty
  end

  it "allows the reporter who created the ticket to close it" do
    expect(controller.status_options_for(reporter, ticket)).to eq([ "closed" ])
  end

  it "allows the reporting user to resubmit a rejected ticket" do
    ticket.status = "rejected"

    expect(controller.status_options_for(reporter, ticket)).to eq(%w[submitted closed])
  end

  it "offers Submitted for a reporter's ticket that is already submitted" do
    ticket.status = "submitted"

    expect(controller.status_options_for(reporter, ticket)).to eq(%w[submitted closed])
  end

  it "does not allow the reporting user to resubmit a ticket that was not rejected" do
    expect(controller.status_options_for(reporter, ticket)).not_to include("submitted")
  end

  it "does not allow a reporter who did not create the ticket to change its status" do
    ticket.reporter_id = 4
    ticket.status = "rejected"

    expect(controller.status_options_for(reporter, ticket)).to eq([])
  end

  describe "#update_status" do
    before do
      controller.define_singleton_method(:current_user) { current_user_for_update }
      controller.define_singleton_method(:params) do
        ActionController::Parameters.new(
          id: "12",
          status: requested_status_for_update,
          confirm_closure: closure_confirmation_for_update
        )
      end
      controller.define_singleton_method(:maintenance_ticket_path) { |record| "/issues/#{record.id}" }
      allow(MaintenanceTicket).to receive(:find).with("12").and_return(ticket)
      allow(controller).to receive(:redirect_to)
    end

    def update_status_as(user, status, confirm_closure: nil)
      controller.define_singleton_method(:current_user_for_update) { user }
      controller.define_singleton_method(:requested_status_for_update) { status }
      controller.define_singleton_method(:closure_confirmation_for_update) { confirm_closure }
      controller.update_status
    end

    it "updates a ticket to an allowed manager status" do
      ticket.status = "submitted"
      expect(ticket).to receive(:update).with(status: "assigned").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        flash: { status_update: "Moved status from Submitted to Assigned" }
      )

      update_status_as(manager, "assigned")
    end

    it "does not update or confirm a ticket when its status is unchanged" do
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with("/issues/12")

      update_status_as(manager, "assigned")
    end

    it "does not update a reporter's ticket when they keep it submitted" do
      ticket.status = "submitted"
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with("/issues/12")

      update_status_as(reporter, "submitted")
    end

    it "rejects a manager closing a ticket they did not create" do
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        alert: "You are not allowed to set this status."
      )

      update_status_as(manager, "closed")
    end

    it "allows a manager to close a ticket they created" do
      ticket.reporter_id = manager.id
      expect(ticket).to receive(:update).with(status: "closed").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        flash: { status_update: "Moved status from Assigned to Closed" }
      )

      update_status_as(manager, "closed", confirm_closure: "1")
    end

    it "requires confirmation before closing an eligible ticket" do
      ticket.reporter_id = manager.id
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        alert: "Closing this ticket cannot be undone. Confirm closure to continue."
      )

      update_status_as(manager, "closed")
    end

    it "updates a ticket to an allowed status for its assigned technician" do
      expect(ticket).to receive(:update).with(status: "in_progress").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        flash: { status_update: "Moved status from Assigned to In progress" }
      )

      update_status_as(technician, "in_progress")
    end

    it "rejects a technician setting work status when the ticket is assigned elsewhere" do
      ticket.assigned_technician_id = 4
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        alert: "You are not allowed to set this status."
      )

      update_status_as(technician, "in_progress")
    end

    it "does not allow an unassigned technician to change the status of their own ticket" do
      ticket.assigned_technician_id = nil
      ticket.reporter_id = technician.id
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        alert: "You are not allowed to set this status."
      )

      update_status_as(technician, "closed")
    end

    it "does not allow a technician to update a ticket outside an editable status" do
      ticket.status = "ready_for_verification"
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        alert: "You are not allowed to set this status."
      )

      update_status_as(technician, "in_progress")
    end

    it "does not allow changing a closed ticket's status" do
      ticket.status = "closed"
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        alert: "You are not allowed to set this status."
      )

      update_status_as(manager, "assigned")
    end

    it "allows a reporter to close a ticket they created" do
      expect(ticket).to receive(:update).with(status: "closed").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        flash: { status_update: "Moved status from Assigned to Closed" }
      )

      update_status_as(reporter, "closed", confirm_closure: "1")
    end

    it "allows the reporting user to resubmit a rejected ticket" do
      ticket.status = "rejected"
      expect(ticket).to receive(:update).with(status: "submitted").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        flash: { status_update: "Moved status from Rejected to Submitted" }
      )

      update_status_as(reporter, "submitted")
    end

    it "rejects resubmission when the ticket is not rejected" do
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        alert: "You are not allowed to set this status."
      )

      update_status_as(reporter, "submitted")
    end

    it "rejects a reporter closing a ticket they did not create" do
      ticket.reporter_id = 4
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        alert: "You can only update the status of tickets you reported."
      )

      update_status_as(reporter, "closed")
    end

    it "does not show a status confirmation when the status is unchanged" do
      expect(ticket).not_to receive(:update)
      expect(controller).to receive(:redirect_to).with("/issues/12")

      update_status_as(technician, "assigned")
    end
  end
end
