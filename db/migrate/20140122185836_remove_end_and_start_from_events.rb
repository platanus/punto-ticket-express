class RemoveEndAndStartFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :end
    remove_column :events, :start
  end

  def down
    add_column :events, :start, :datetime
    add_column :events, :end, :datetime
  end
end
