class CreateGlobalConfigurations < ActiveRecord::Migration
  def change
    create_table :global_configurations do |t|
      t.decimal :fixed_fee
      t.decimal :percent_fee

      t.timestamps
    end
  end
end
