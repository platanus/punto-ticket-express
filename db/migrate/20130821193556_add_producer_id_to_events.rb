class AddProducerIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :producer_id, :integer
  end
end
