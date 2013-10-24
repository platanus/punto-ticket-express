class AddEnabledToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :enabled, :boolean, default: true
  end
end
