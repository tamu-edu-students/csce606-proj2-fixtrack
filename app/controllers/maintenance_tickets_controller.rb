class MaintenanceTicketsController < ApplicationController
  TECHNICIAN_VISIBLE_STATUSES = %w[assigned in_progress].freeze
  STATUSES_BEFORE_REPAIR = MaintenanceTicket::STATUSES_BEFORE_REPAIR
  TICKET_ACTION_PARTIALS = {
    "manager" => %w[priority_update technician_assignment].freeze,
    "technician" => %w[repair_record_form].freeze
  }.freeze

  before_action :authenticate_user!
  helper_method :status_options_for

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
    normalize_status_for_repair_records(@maintenance_ticket)
    @repair_records_order = params[:repair_records_order] == "desc" ? "desc" : "asc"
    @ticket_action_partials = TICKET_ACTION_PARTIALS.fetch(current_user.role, [])
    if current_user.technician? &&
       @maintenance_ticket.assigned_technician_id != current_user.id
      @ticket_action_partials = []
    end
  end

  def update_status
    ticket = MaintenanceTicket.find(params[:id])
    requested_status = params[:status]
    previous_status = ticket.status

    unless status_options_for(current_user, ticket).include?(requested_status)
      redirect_to maintenance_ticket_path(ticket),
                  alert: "You are not allowed to set this status."
      return
    end

    if ticket.update(status: requested_status)
      if previous_status == requested_status
        redirect_to maintenance_ticket_path(ticket)
      else
        redirect_to maintenance_ticket_path(ticket),
                    flash: {
                      status_update: "Moved status from #{previous_status.humanize} to #{requested_status.humanize}"
                    }
      end
    else
      redirect_to maintenance_ticket_path(ticket),
                  alert: ticket.errors.full_messages.to_sentence
    end
  end

  def status_options_for(user, ticket)
    MaintenanceTicket.status_options_for(user, ticket)
  end

  private

  def normalize_status_for_repair_records(ticket)
    return unless ticket.repair_records.exists?
    return unless STATUSES_BEFORE_REPAIR.include?(ticket.status)

    ticket.update!(status: "in_progress")
  end

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
