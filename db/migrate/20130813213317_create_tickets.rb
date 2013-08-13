class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :user_id
      t.integer :ticket_type_id
      t.string :payment_type
      t.integer :quantity

      t.timestamps
    end
  end
end
