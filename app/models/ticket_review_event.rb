class TicketReviewEvent < ApplicationRecord
  EVENT_TYPES = %w[verified reopened].freeze

  belongs_to :maintenance_ticket
  belongs_to :actor, class_name: "User"

  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :previous_status, :new_status, presence: true
  validates :reason, presence: true,
                     if: -> { event_type == "reopened" || manager_override? }
end
