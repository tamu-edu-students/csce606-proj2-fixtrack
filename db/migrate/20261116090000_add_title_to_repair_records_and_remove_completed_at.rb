class AddTitleToRepairRecordsAndRemoveCompletedAt < ActiveRecord::Migration[8.1]
  def up
    add_column :repair_records, :title, :string

    select_all("SELECT id, description FROM repair_records").each do |record|
      title = record["description"].to_s.split.join(" ")[0, 255]
      title = "Repair record #{record['id']}" if title.empty?
      execute <<~SQL.squish
        UPDATE repair_records
        SET title = #{connection.quote(title)}
        WHERE id = #{record["id"].to_i}
      SQL
    end

    change_column_null :repair_records, :title, false
    remove_column :repair_records, :completed_at, :datetime
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
