class ChangeDateFormatInPromotions < ActiveRecord::Migration
  def up
   change_column :promotions, :start_date, :datetime
  end

  def down
   change_column :promotions, :start_date, :date
  end
end
