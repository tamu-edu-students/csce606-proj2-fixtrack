class CreateTicketReviewEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_review_events do |t|
      t.references :maintenance_ticket, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }

      t.string :event_type, null: false
      t.string :previous_status, null: false
      t.string :new_status, null: false
      t.text :reason
      t.boolean :manager_override, null: false, default: false

      t.timestamps
    end
  end
end
