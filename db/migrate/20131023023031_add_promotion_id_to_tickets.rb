class AddPromotionIdToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :promotion_id, :integer
  end
end
