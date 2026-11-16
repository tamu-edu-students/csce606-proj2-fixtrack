class RepairRecord < ApplicationRecord
  belongs_to :maintenance_ticket
  belongs_to :technician, class_name: "User"

  validates :title, presence: true
end
