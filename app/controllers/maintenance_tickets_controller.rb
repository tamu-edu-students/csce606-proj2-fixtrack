class MaintenanceTicketsController < ApplicationController
  STATUS_OPTIONS_BY_ROLE = {
    "manager" => %w[submitted rejected assigned closed],
    "technician" => %w[assigned in_progress ready_for_verification]
  }.freeze

  before_action :authenticate_user!
  helper_method :status_options_for, :can_update_status?

  def new
    @maintenance_ticket = MaintenanceTicket.new
  end

  def create
    @maintenance_ticket = MaintenanceTicket.new(ticket_params)
    @maintenance_ticket.reporter = current_user

    if @maintenance_ticket.save
      redirect_to @maintenance_ticket,
                  notice: "Maintenance ticket created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @maintenance_ticket = MaintenanceTicket.find(params[:id])
  end

  def update_status
    ticket = MaintenanceTicket.find(params[:id])
    requested_status = params[:status]

    unless can_update_status?(ticket)
      redirect_to maintenance_ticket_path(ticket),
                  alert: "You can only update the status of tickets assigned to you."
      return
    end

    unless status_options_for(current_user).include?(requested_status)
      redirect_to maintenance_ticket_path(ticket),
                  alert: "You are not allowed to set this status."
      return
    end

    if ticket.update(status: requested_status)
      redirect_to maintenance_ticket_path(ticket),
                  notice: "Ticket status updated."
    else
      redirect_to maintenance_ticket_path(ticket),
                  alert: ticket.errors.full_messages.to_sentence
    end
  end

  def status_options_for(user)
    STATUS_OPTIONS_BY_ROLE.fetch(user&.role, [])
  end

  def can_update_status?(ticket, user = current_user)
    return false unless user
    return true if user.role == "manager"

    user.role == "technician" && ticket.assigned_technician_id == user.id
  end

  private

  def ticket_params
    params.require(:maintenance_ticket).permit(
      :title,
      :description,
      :priority,
      :equipment_id
    )
  end
end
