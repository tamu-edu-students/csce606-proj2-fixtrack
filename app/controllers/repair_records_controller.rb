class RepairRecordsController < ApplicationController
  before_action :authenticate_user!

  def create
    unless current_user.technician?
      redirect_to maintenance_tickets_path,
                  alert: "Only technicians can add repair records."
      return
    end

    @maintenance_ticket = MaintenanceTicket
      .where(assigned_technician: current_user)
      .find(params[:maintenance_ticket_id])
    @repair_record = @maintenance_ticket.repair_records.build(repair_record_params)
    @repair_record.technician = current_user

    previous_status = nil
    @maintenance_ticket.with_lock do
      previous_status = @maintenance_ticket.status
      if @repair_record.save && @maintenance_ticket.status != "in_progress"
        @maintenance_ticket.update!(status: "in_progress")
      end
    end

    if @repair_record.persisted?
      if previous_status != @maintenance_ticket.status
        redirect_to maintenance_ticket_path(@maintenance_ticket),
                    flash: {
                      status_update: "Moved status from #{previous_status.humanize} to #{@maintenance_ticket.status.humanize}"
                    }
      else
        redirect_to maintenance_ticket_path(@maintenance_ticket),
                    notice: "Repair record added."
      end
    else
      @ticket_action_partials = [ "repair_record_form" ]
      @repair_records_order = params[:repair_records_order] == "desc" ? "desc" : "asc"
      @new_repair_record = @repair_record
      render "maintenance_tickets/show", status: :unprocessable_entity
    end
  end

  def edit
    return unless prepare_repair_record_modification

    @repair_record = @maintenance_ticket.repair_records.find(params[:id])
  end

  def update
    return unless prepare_repair_record_modification

    @repair_record = @maintenance_ticket.repair_records.find(params[:id])

    if @repair_record.update(repair_record_params)
      redirect_to maintenance_ticket_path(@maintenance_ticket),
                  flash: { repair_record_update: "Repair record updated." }
    elsif params[:panel_edit] == "true"
      @ticket_action_partials = [ "repair_record_form" ]
      @new_repair_record = @maintenance_ticket.repair_records.build
      @repair_records_order = params[:repair_records_order] == "desc" ? "desc" : "asc"
      @active_repair_panel_id = @repair_record.id
      render "maintenance_tickets/show", status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    return unless prepare_repair_record_modification

    repair_record = @maintenance_ticket.repair_records.find(params[:id])
    repair_record.destroy!

    redirect_to maintenance_ticket_path(@maintenance_ticket),
                notice: "Repair record deleted."
  end

  private

  def repair_record_params
    params.require(:repair_record).permit(:title, :description)
  end

  def prepare_repair_record_modification
    unless current_user.technician?
      redirect_to maintenance_tickets_path,
                  alert: "Only the assigned technician can manage repair records."
      return false
    end

    @maintenance_ticket = MaintenanceTicket
      .where(assigned_technician: current_user)
      .find(params[:maintenance_ticket_id])

    return true if %w[assigned in_progress].include?(@maintenance_ticket.status)

    redirect_to maintenance_ticket_path(@maintenance_ticket),
                alert: "Repair records can only be changed while the ticket is assigned or in progress."
    false
  end
end
