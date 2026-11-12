class MaintenanceTicket < ApplicationRecord
  STATUSES = %w[
    submitted rejected assigned in_progress ready_for_verification closed
  ].freeze

  belongs_to :equipment
  belongs_to :reporter, class_name: "User"
  belongs_to :assigned_technician,
             class_name: "User",
             optional: true

  validates :title, presence: true
  validates :description, presence: true

  validates :priority,
            presence: true,
            inclusion: { in: %w[low medium high] }

  validates :status,
            presence: true,
            inclusion: { in: STATUSES }

  validate :equipment_id_must_reference_existing_equipment

  private

  def equipment_id_must_reference_existing_equipment
    return if equipment_id.blank?

    unless Equipment.exists?(id: equipment_id)
      errors.add(:equipment_id, "must reference existing equipment")
    end
  end
end
