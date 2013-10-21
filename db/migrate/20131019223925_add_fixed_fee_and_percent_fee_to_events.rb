class AddFixedFeeAndPercentFeeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :fixed_fee, :decimal
    add_column :events, :percent_fee, :decimal
  end
end
