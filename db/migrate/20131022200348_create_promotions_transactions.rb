class CreatePromotionsTransactions < ActiveRecord::Migration
  def change
    create_table :promotions_transactions do |t|
      t.belongs_to :transaction
      t.belongs_to :promotion
    end
  end
end
