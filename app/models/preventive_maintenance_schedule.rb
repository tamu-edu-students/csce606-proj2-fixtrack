class PreventiveMaintenanceSchedule < ApplicationRecord
  belongs_to :equipment, inverse_of: :preventive_maintenance_schedules

  normalizes :task, with: ->(value) { value.strip }

  validates :task, :due_date, presence: true
  validate :due_date_must_be_future, on: :create

  private

  def due_date_must_be_future
    return if due_date.blank? || due_date > Date.current

    errors.add(:due_date, "must be after today")
  end
end
