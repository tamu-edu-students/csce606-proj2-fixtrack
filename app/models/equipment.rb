class Equipment < ApplicationRecord
  STATUSES = [ "Available", "Under Maintenance", "Out of Service" ].freeze

  normalizes :name, :asset_identifier, :location, with: ->(value) { value.strip }

  validates :name, :asset_identifier, :location, :status, presence: true
  validates :asset_identifier, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  def self.search(query)
    term = query.to_s.strip
    return all if term.empty?

    pattern = "%#{sanitize_sql_like(term.downcase)}%"
    where("LOWER(name) LIKE :pattern ESCAPE '\\' OR LOWER(asset_identifier) LIKE :pattern ESCAPE '\\'", pattern: pattern)
  end

  # Ticket ownership and history restrictions will be added with the ticket model.
end
