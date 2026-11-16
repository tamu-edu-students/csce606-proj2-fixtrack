class MaintenanceTicket < ApplicationRecord
  STATUSES = %w[
    submitted rejected assigned in_progress ready_for_verification closed
  ].freeze
  STATUS_OPTIONS_BY_ROLE = {
    "manager" => %w[submitted rejected assigned],
    "technician" => %w[assigned in_progress ready_for_verification]
  }.freeze
  STATUSES_BEFORE_REPAIR = %w[submitted rejected assigned].freeze

  belongs_to :equipment
  belongs_to :reporter, class_name: "User"
  belongs_to :assigned_technician,
             class_name: "User",
             optional: true

  has_many :repair_records

  def self.status_options_for(user, ticket)
    return [] unless user

    statuses = STATUS_OPTIONS_BY_ROLE.fetch(user.role, [])
    has_repair_records = ticket.repair_records.exists?
    if user.role == "technician" && ticket.assigned_technician_id != user.id
      statuses = []
    end
    statuses -= STATUSES_BEFORE_REPAIR if has_repair_records
    if !has_repair_records && ticket.status == "rejected" && ticket.reporter_id == user.id
      statuses += [ "submitted" ]
    end
    statuses += [ "closed" ] if ticket.reporter_id == user.id
    statuses
  end

  validates :title, presence: true
  validates :description, presence: true

  validates :priority,
            presence: true,
            inclusion: { in: %w[low medium high] }

  validates :status,
            presence: true,
            inclusion: { in: STATUSES }

  validate :equipment_id_must_reference_existing_equipment
  validate :assigned_technician_must_be_eligible

  private

  def assigned_technician_must_be_eligible
    # Unassigned tickets are valid; a selected user must exist and be a technician.
    return if assigned_technician_id.blank?
    return if assigned_technician&.technician?

    errors.add(:assigned_technician, "must be an existing technician")
  end

  def equipment_id_must_reference_existing_equipment
    return if equipment_id.blank?

    unless Equipment.exists?(id: equipment_id)
      errors.add(:equipment_id, "must reference existing equipment")
    end
  end
end
