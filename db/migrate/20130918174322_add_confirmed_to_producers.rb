class AddConfirmedToProducers < ActiveRecord::Migration
  def change
    add_column :producers, :confirmed, :boolean, default: false
  end
end
