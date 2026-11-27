
class TicketReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket

  def verify
    process_review(
      "verified",
      "closed",
      %w[ready_for_verification]
    )
  end

  def reopen
    process_review(
      "reopened",
      "in_progress",
      %w[ready_for_verification closed]
    )
  end

  private

  def set_ticket
    @ticket = MaintenanceTicket.find(params[:id])
  end

  def process_review(event_type, new_status, allowed_statuses)
    return head :forbidden unless @ticket.reviewable_by?(current_user)

    manager_override = @ticket.manager_override_by?(current_user)
    reason = params[:reason].to_s.strip

    if (event_type == "reopened" || manager_override) && reason.blank?
      redirect_to maintenance_ticket_path(@ticket),
                  alert: "A reason is required.",
                  status: :see_other
      return
    end

    invalid_state = false

    @ticket.with_lock do
      if allowed_statuses.exclude?(@ticket.status)
        invalid_state = true
      else
        previous_status = @ticket.status

        @ticket.update!(status: new_status)

        @ticket.ticket_review_events.create!(
          actor: current_user,
          event_type: event_type,
          previous_status: previous_status,
          new_status: new_status,
          reason: reason.presence,
          manager_override: manager_override
        )
      end
    end

    if invalid_state
      redirect_to maintenance_ticket_path(@ticket),
                  alert: "This ticket is not in a valid state for this action.",
                  status: :see_other
      return
    end

    message = event_type == "verified" ?
      "Repair verified and ticket closed." :
      "Ticket reopened for further repair."

    redirect_to maintenance_ticket_path(@ticket),
                status: :see_other,
                flash: { status_update: message }
  rescue ActiveRecord::RecordInvalid => error
    redirect_to maintenance_ticket_path(@ticket),
                alert: error.record.errors.full_messages.to_sentence,
                status: :see_other
  end
end
