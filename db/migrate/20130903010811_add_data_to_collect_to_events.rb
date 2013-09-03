class AddDataToCollectToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :data_to_collect, :text
  end
end
