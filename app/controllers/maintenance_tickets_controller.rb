class MaintenanceTicketsController < ApplicationController
  TECHNICIAN_VISIBLE_STATUSES = %w[assigned in_progress].freeze
  STATUSES_BEFORE_REPAIR = MaintenanceTicket::STATUSES_BEFORE_REPAIR
  TICKET_ACTION_PARTIALS = {
    "manager" => %w[technician_assignment].freeze,
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
    prepare_ticket_details
  end

  def update_priority
    @maintenance_ticket = MaintenanceTicket.find(params[:id])
    authorize @maintenance_ticket, :update_priority?

    if @maintenance_ticket.update(priority_params)
      redirect_to maintenance_ticket_path(@maintenance_ticket),
                  status: :see_other,
                  flash: { priority_update: "Ticket priority updated successfully." }
    else
      # Rebuild the detail page without show's status-normalization side effect.
      prepare_ticket_details
      render :show, status: :unprocessable_entity
    end
  rescue Pundit::NotAuthorizedError
    render plain: "You are not allowed to update ticket priority.", status: :forbidden
  end

  def update_assignment
    @maintenance_ticket = MaintenanceTicket.find(params[:id])
    authorize @maintenance_ticket, :update_assignment?

    if @maintenance_ticket.update_assignment(assignment_params[:assigned_technician_id])
      redirect_to maintenance_ticket_path(@maintenance_ticket),
                  status: :see_other,
                  flash: { technician_assignment: "Ticket technician assignment updated successfully." }
    else
      # Rebuild the detail page without show's status-normalization side effect.
      prepare_ticket_details
      render :show, status: :unprocessable_entity
    end
  rescue Pundit::NotAuthorizedError
    render plain: "You are not allowed to change ticket assignments.", status: :forbidden
  end

  def update_status
    ticket = MaintenanceTicket.find(params[:id])
    requested_status = params[:status]

    unless status_options_for(current_user, ticket).include?(requested_status)
      alert_message =
        if current_user&.role == "reporter" && ticket.reporter_id != current_user.id
          "You can only update the status of tickets you reported."
        else
          "You are not allowed to set this status."
        end
      redirect_to maintenance_ticket_path(ticket),
                  alert: alert_message
      return
    end

    previous_status = ticket.status
    if requested_status == previous_status
      redirect_to maintenance_ticket_path(ticket)
      return
    end

    if ticket.update(status: requested_status)
      redirect_to maintenance_ticket_path(ticket),
                  flash: {
                    status_update: "Moved status from #{previous_status.humanize} to #{requested_status.humanize}"
                  }
    else
      redirect_to maintenance_ticket_path(ticket),
                  alert: ticket.errors.full_messages.to_sentence
    end
  end

  def status_options_for(user, ticket)
    MaintenanceTicket.status_options_for(user, ticket)
  end

  private

  def prepare_ticket_details
    @repair_records_order = params[:repair_records_order] == "desc" ? "desc" : "asc"
    @ticket_action_partials = TICKET_ACTION_PARTIALS.fetch(current_user.role, []).dup
    # Priority access includes Admins, so use the same policy as the endpoint.
    @ticket_action_partials.unshift("priority_update") if policy(@maintenance_ticket).update_priority?
    if current_user.technician? &&
       @maintenance_ticket.assigned_technician_id != current_user.id
      @ticket_action_partials = []
    end
  end

  def priority_params
    # Require the nested priority payload; leave blank-value checks to the model.
    params.expect(maintenance_ticket: [ :priority ])
  end

  def assignment_params
    permitted = params.expect(maintenance_ticket: [ :assigned_technician_id ])
    # A missing field is malformed; an explicit nil or blank requests clearing.
    unless permitted.key?(:assigned_technician_id)
      raise ActionController::ParameterMissing, :assigned_technician_id
    end

    permitted
  end

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
