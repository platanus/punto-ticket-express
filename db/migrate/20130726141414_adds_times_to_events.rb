class AddsTimesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :start_data_time, :datetime
    add_column :events, :end_data_time, :datetime
  end
end
