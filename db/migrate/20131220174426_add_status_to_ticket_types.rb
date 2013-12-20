class AddStatusToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :status, :integer, default: 1
  end
end
