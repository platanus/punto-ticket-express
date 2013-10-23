class AddTicketTypeIdToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :ticket_type_id, :integer
  end
end
