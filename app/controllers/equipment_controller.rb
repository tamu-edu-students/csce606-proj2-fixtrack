class EquipmentController < ApplicationController
  before_action :authenticate_user!
  before_action :set_equipment, only: [ :show, :edit, :update, :confirm_destroy, :destroy ]

  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError do
    head :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do
    render plain: "Equipment not found.", status: :not_found
  end

  def index
    authorize Equipment
    @equipment = Equipment.order(:name, :id)
  end

  def show
    authorize @equipment
    @open_tickets = @equipment.maintenance_tickets.outstanding.order(created_at: :desc, id: :desc)
  end

  def new
    @equipment = Equipment.new
    authorize @equipment
  end

  def create
    @equipment = Equipment.new(equipment_params)
    authorize @equipment
    if @equipment.save
      redirect_to equipment_path(@equipment), notice: "Equipment created successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @equipment
  end

  def update
    authorize @equipment
    if @equipment.update(equipment_params)
      redirect_to equipment_path(@equipment), notice: "Equipment updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def confirm_destroy
    authorize @equipment
  end

  def destroy
    authorize @equipment
    if @equipment.destroy
      redirect_to equipment_index_path, notice: "Equipment removed successfully.", status: :see_other
    else
      redirect_to equipment_path(@equipment),
        alert: @equipment.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_equipment
    @equipment = Equipment.find(params[:id])
  end

  def equipment_params
    params.require(:equipment).permit(
      :name,
      :asset_identifier,
      :description,
      :location,
      :status,
      :manufacture_date,
      :specifications
    )
  end
end
