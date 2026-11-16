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

    if @repair_record.save
      redirect_to maintenance_ticket_path(@maintenance_ticket),
                  notice: "Repair record added."
    else
      @ticket_action_partials = [ "repair_record_form" ]
      render "maintenance_tickets/show", status: :unprocessable_entity
    end
  end

  private

  def repair_record_params
    params.require(:repair_record).permit(:description, :completed_at)
  end
end
