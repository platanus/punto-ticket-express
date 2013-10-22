class AddIncludeFeeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :include_fee, :boolean
  end
end
