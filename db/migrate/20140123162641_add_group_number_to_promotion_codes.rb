class AddGroupNumberToPromotionCodes < ActiveRecord::Migration
  def change
    add_column :promotion_codes, :group_number, :integer
  end
end
