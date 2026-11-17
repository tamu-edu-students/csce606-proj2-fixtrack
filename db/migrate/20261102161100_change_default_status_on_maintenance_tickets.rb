class ChangeDefaultStatusOnMaintenanceTickets < ActiveRecord::Migration[8.1]
  def change
    change_column_default :maintenance_tickets, :status, from: "open", to: "submitted"
  end
end
