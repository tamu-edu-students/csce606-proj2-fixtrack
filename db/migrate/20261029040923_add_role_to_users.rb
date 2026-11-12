class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def up
    # Preserve users created by the older Devise migration while matching schema.rb.
    add_column :users, :role, :string unless column_exists?(:users, :role)
    change_column_default :users, :role, nil
    change_column_null :users, :role, true
  end

  def down
    remove_column :users, :role
  end
end
