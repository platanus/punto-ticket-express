class AddSellLimitToGlobalConfigurations < ActiveRecord::Migration
  def change
    add_column :global_configurations, :sell_limit, :integer, default: 50
  end
end
