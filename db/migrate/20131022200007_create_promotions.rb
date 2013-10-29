class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :name
      t.string :promotion_type
      t.date :start_date
      t.date :end_date
      t.integer :limit
      t.string :activation_code
      t.string :promotion_type_config

      t.timestamps
    end
  end
end
