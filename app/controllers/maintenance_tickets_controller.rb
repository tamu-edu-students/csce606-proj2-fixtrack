class MaintenanceTicketsController < ApplicationController
  STATUS_OPTIONS_BY_ROLE = {
    "manager" => %w[submitted rejected assigned closed],
    "technician" => %w[assigned in_progress ready_for_verification]
  }.freeze

  before_action :authenticate_user!
  helper_method :status_options_for

  def update_status
    ticket = MaintenanceTicket.find(params[:id])
    requested_status = params[:status]

    unless status_options_for(current_user).include?(requested_status)
      redirect_back_or_to("/", alert: "You are not allowed to set that status.")
      return
    end

    if ticket.update(status: requested_status)
      redirect_back_or_to("/", notice: "Ticket status updated.")
    else
      redirect_back_or_to("/", alert: ticket.errors.full_messages.to_sentence)
    end
  end

  def status_options_for(user)
    STATUS_OPTIONS_BY_ROLE.fetch(user&.role, [])
  end
end
