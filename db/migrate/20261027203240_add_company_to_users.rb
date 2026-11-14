class AddCompanyToUsers < ActiveRecord::Migration[8.1]
  def up
    # Older copies of DeviseCreateUsers already added this reference.
    add_reference :users, :company, null: false, foreign_key: true unless column_exists?(:users, :company_id)
  end

  def down
    remove_reference :users, :company, foreign_key: true
  end
end
