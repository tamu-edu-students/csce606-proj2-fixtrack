class MaintenanceTicketsController < ApplicationController
  TECHNICIAN_VISIBLE_STATUSES = %w[assigned in_progress].freeze

  before_action :authenticate_user!

  def index
    @maintenance_tickets = ticket_scope.order(created_at: :desc)
  end

  def new
    @maintenance_ticket = MaintenanceTicket.new
  end

  def create
    @maintenance_ticket = MaintenanceTicket.new(ticket_params)
    @maintenance_ticket.reporter = current_user

    if @maintenance_ticket.save
      if current_user.technician?
        redirect_to maintenance_tickets_path,
                    notice: "Maintenance ticket created successfully."
      else
        redirect_to @maintenance_ticket,
                    notice: "Maintenance ticket created successfully."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @maintenance_ticket = ticket_scope.find(params[:id])
  end

  private

  def ticket_scope
    return MaintenanceTicket.all unless current_user&.technician?

    MaintenanceTicket.where(
      assigned_technician: current_user,
      status: TECHNICIAN_VISIBLE_STATUSES
    )
  end

  def ticket_params
    params.require(:maintenance_ticket).permit(
      :title,
      :description,
      :priority,
      :equipment_id
    )
  end
end
