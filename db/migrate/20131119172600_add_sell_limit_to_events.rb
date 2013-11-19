class AddSellLimitToEvents < ActiveRecord::Migration
  def change
    add_column :events, :sell_limit, :integer
  end
end
