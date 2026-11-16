class CreateRepairRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :repair_records do |t|
      t.references :maintenance_ticket, null: false, foreign_key: true
      t.references :technician, null: false, foreign_key: { to_table: :users }
      t.text :description, null: false
      t.datetime :completed_at, null: false

      t.timestamps
    end
  end
end
