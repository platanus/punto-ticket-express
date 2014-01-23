class CreatePromotionCodes < ActiveRecord::Migration
  def change
    create_table :promotion_codes do |t|
      t.string :code
      t.integer :user_id

      t.timestamps
    end
  end
end
