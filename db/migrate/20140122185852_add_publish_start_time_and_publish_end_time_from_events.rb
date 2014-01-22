class AddPublishStartTimeAndPublishEndTimeFromEvents < ActiveRecord::Migration
  def change
    add_column :events, :publish_start_time, :datetime
    add_column :events, :publish_end_time, :datetime
  end
end
