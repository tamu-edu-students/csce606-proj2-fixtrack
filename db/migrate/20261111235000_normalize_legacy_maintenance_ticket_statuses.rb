class NormalizeLegacyMaintenanceTicketStatuses < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE maintenance_tickets SET status = 'submitted' WHERE status = 'open'"
    execute "UPDATE maintenance_tickets SET status = 'closed' WHERE status = 'resolved'"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
