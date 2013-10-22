class AddPromotionIdToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :promotion_id, :integer
  end
end
