class AddDefaultValueToIsPublishedInEvents < ActiveRecord::Migration
  def up
    change_column :events, :is_published, :boolean, :default => false
  end

  def down
    change_column :events, :is_published, :boolean, :default => nil
  end
end
