class PreventiveMaintenanceSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_schedule_access!
  before_action :set_equipment
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError do
    head :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do
    render plain: "Equipment not found.", status: :not_found
  end

  def index
    @schedules = @equipment.preventive_maintenance_schedules.order(:due_date, :id)
  end

  def new
    @schedule = @equipment.preventive_maintenance_schedules.build
  end

  def create
    @schedule = @equipment.preventive_maintenance_schedules.build(schedule_params)
    if @schedule.save
      redirect_to equipment_preventive_maintenance_schedules_path(@equipment),
        notice: "Preventive maintenance scheduled successfully.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def authorize_schedule_access!
    authorize PreventiveMaintenanceSchedule, action_name == "index" ? :index? : :create?
  end

  def set_equipment
    @equipment = Equipment.find(params[:equipment_id])
  end

  def schedule_params
    params.require(:preventive_maintenance_schedule).permit(:task, :due_date)
  end
end
