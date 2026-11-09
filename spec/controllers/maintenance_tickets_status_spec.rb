require "rails_helper"

RSpec.describe MaintenanceTicketsController do
  subject(:controller) { described_class.new }

  let(:manager) { Struct.new(:id, :role).new(1, "manager") }
  let(:technician) { Struct.new(:id, :role).new(2, "technician") }
  let(:reporter) { Struct.new(:id, :role).new(3, "reporter") }
  let(:ticket) do
    ticket_class = Struct.new(:id, :assigned_technician_id, :reporter_id, :status) do
      def update(**_attributes)
        true
      end
    end
    ticket_class.new(12, technician.id, reporter.id, "assigned")
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

    expect(controller.status_options_for(technician, ticket)).to eq([ "closed" ])
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
        ActionController::Parameters.new(id: "12", status: requested_status_for_update)
      end
      controller.define_singleton_method(:maintenance_ticket_path) { |record| "/issues/#{record.id}" }
      allow(MaintenanceTicket).to receive(:find).with("12").and_return(ticket)
      allow(controller).to receive(:redirect_to)
    end

    def update_status_as(user, status)
      controller.define_singleton_method(:current_user_for_update) { user }
      controller.define_singleton_method(:requested_status_for_update) { status }
      controller.update_status
    end

    it "updates a ticket to an allowed manager status" do
      expect(ticket).to receive(:update).with(status: "assigned").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        notice: "Ticket status updated."
      )

      update_status_as(manager, "assigned")
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
        notice: "Ticket status updated."
      )

      update_status_as(manager, "closed")
    end

    it "updates a ticket to an allowed status for its assigned technician" do
      expect(ticket).to receive(:update).with(status: "in_progress").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        notice: "Ticket status updated."
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

    it "allows a technician creator to close their own ticket even when unassigned" do
      ticket.assigned_technician_id = nil
      ticket.reporter_id = technician.id
      expect(ticket).to receive(:update).with(status: "closed").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        notice: "Ticket status updated."
      )

      update_status_as(technician, "closed")
    end

    it "allows a reporter to close a ticket they created" do
      expect(ticket).to receive(:update).with(status: "closed").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        notice: "Ticket status updated."
      )

      update_status_as(reporter, "closed")
    end

    it "allows the reporting user to resubmit a rejected ticket" do
      ticket.status = "rejected"
      expect(ticket).to receive(:update).with(status: "submitted").and_return(true)
      expect(controller).to receive(:redirect_to).with(
        "/issues/12",
        notice: "Ticket status updated."
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
        alert: "You are not allowed to set this status."
      )

      update_status_as(reporter, "closed")
    end
  end
end
