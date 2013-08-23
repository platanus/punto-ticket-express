class ChangeColumnsFromTickets < ActiveRecord::Migration
  def up
    remove_column :tickets, :payment_status
    remove_column :tickets, :quantity
    remove_column :tickets, :user_id
    add_column :tickets, :transaction_id, :integer
  end

  def down
    add_column :tickets, :payment_status, :string
    add_column :tickets, :quantity, :integer
    add_column :tickets, :user_id, :integer
    remove_column :tickets, :transaction_id
  end
end
