class AddIdentifierToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :identifier, :string
  end
end
