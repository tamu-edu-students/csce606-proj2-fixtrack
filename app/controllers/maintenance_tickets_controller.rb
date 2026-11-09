class MaintenanceTicketsController < ApplicationController
  STATUS_OPTIONS_BY_ROLE = {
    "manager" => %w[submitted rejected assigned],
    "technician" => %w[assigned in_progress ready_for_verification]
  }.freeze

  before_action :authenticate_user!
  helper_method :status_options_for

  def index
    @maintenance_tickets = MaintenanceTicket.order(created_at: :desc)
  end

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

    unless status_options_for(current_user, ticket).include?(requested_status)
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

  def status_options_for(user, ticket)
    return [] unless user

    statuses = STATUS_OPTIONS_BY_ROLE.fetch(user.role, [])
    if user.role == "technician" && ticket.assigned_technician_id != user.id
      statuses = []
    end
    statuses += [ "closed" ] if ticket.reporter_id == user.id
    statuses
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
