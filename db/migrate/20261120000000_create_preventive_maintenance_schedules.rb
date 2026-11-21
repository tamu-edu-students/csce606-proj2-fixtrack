class CreatePreventiveMaintenanceSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :preventive_maintenance_schedules do |t|
      t.references :equipment, null: false, foreign_key: true, index: false
      t.string :task, null: false
      t.date :due_date, null: false
      t.timestamps
    end

    add_index :preventive_maintenance_schedules, [ :equipment_id, :due_date ]
  end
end
