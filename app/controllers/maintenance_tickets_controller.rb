class MaintenanceTicketsController < ApplicationController
  TECHNICIAN_VISIBLE_STATUSES = %w[assigned in_progress].freeze
  TICKET_ACTION_PARTIALS = {
    "manager" => %w[priority_update technician_assignment].freeze,
    "technician" => %w[repair_record_form].freeze
  }.freeze

  before_action :authenticate_user!

  def index
    @maintenance_tickets = ticket_scope.order(created_at: :desc)
    @empty_state_message = current_user.technician? ? "You have no tickets to work on." : "No issues have been reported."
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
    @maintenance_ticket = show_scope.find(params[:id])
    @ticket_action_partials = TICKET_ACTION_PARTIALS.fetch(current_user.role, [])
  end

  private

  def ticket_scope
    return MaintenanceTicket.all unless current_user&.technician?

    technician_ticket_scope
  end

  def show_scope
    return MaintenanceTicket.all unless current_user&.technician?

    technician_ticket_scope.or(MaintenanceTicket.where(reporter: current_user))
  end

  def technician_ticket_scope
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
