class AddFixedFeeAndPercentFeeToProducers < ActiveRecord::Migration
  def change
    add_column :producers, :fixed_fee, :decimal
    add_column :producers, :percent_fee, :decimal
  end
end
