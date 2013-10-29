class ChangePromotionTypeConfigType < ActiveRecord::Migration
  def up
    change_column(:promotions, :promotion_type_config, :decimal)
  end

  def down
    change_column(:promotions, :promotion_type_config, :string)
  end
end
