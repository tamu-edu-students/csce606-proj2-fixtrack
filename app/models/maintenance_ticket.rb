class MaintenanceTicket < ApplicationRecord
  STATUSES = %w[
    submitted rejected assigned in_progress ready_for_verification closed
  ].freeze
  STATUS_OPTIONS_BY_ROLE = {
    "manager" => %w[submitted rejected assigned],
    "technician" => %w[assigned in_progress ready_for_verification]
  }.freeze
  STATUSES_BEFORE_REPAIR = %w[submitted rejected assigned].freeze
  ASSIGNABLE_STATUSES = %w[submitted assigned in_progress].freeze

  belongs_to :equipment
  belongs_to :reporter, class_name: "User"
  belongs_to :assigned_technician,
             class_name: "User",
             optional: true

  has_many :repair_records

  def assignment_allowed?
    ASSIGNABLE_STATUSES.include?(status)
  end

  def update_assignment(technician_id)
    errors.clear
    unless assignment_allowed?
      errors.add(:status, "does not allow technician assignment changes")
      return false
    end

    # Reject malformed IDs before Rails can cast them to nil (clearing) or another ID.
    unless technician_id.nil? || technician_id == "" ||
           ((technician_id.is_a?(String) || technician_id.is_a?(Integer)) &&
            technician_id.to_s.match?(/\A[1-9][0-9]*\z/))
      errors.add(:assigned_technician, "must be an existing technician")
      return false
    end

    next_status = status
    if technician_id.present? && status == "submitted"
      next_status = "assigned"
    elsif technician_id.blank? && status == "assigned" && !repair_records.exists?
      next_status = "submitted"
    end

    # One save keeps assignment and status atomic; started work retains its status.
    update(assigned_technician_id: technician_id, status: next_status)
  end

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
