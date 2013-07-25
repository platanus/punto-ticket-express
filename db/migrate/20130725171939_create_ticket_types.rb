class CreateTicketTypes < ActiveRecord::Migration
  def change
    create_table :ticket_types do |t|
      t.integer :event_id
      t.string :name
      t.integer :price
      t.integer :quantity

      t.timestamps
    end
  end
end
