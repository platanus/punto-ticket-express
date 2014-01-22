class ChangePromotionStartAndEndDateTypes < ActiveRecord::Migration
  def up
    change_column(:promotions, :start_date, :datetime)
    change_column(:promotions, :end_date, :datetime)
  end

  def down
    change_column(:promotions, :start_date, :date)
    change_column(:promotions, :end_date, :date)
  end
end
