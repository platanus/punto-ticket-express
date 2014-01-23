class AddPromotionIdToPromotionCodes < ActiveRecord::Migration
  def change
    add_column :promotion_codes, :promotion_id, :integer
  end
end
