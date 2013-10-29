class DeletePromotionsTransactions < ActiveRecord::Migration
  def up
    drop_table :promotions_transactions
  end

  def down
    create_table :promotions_transactions do |t|
      t.belongs_to :transaction
      t.belongs_to :promotion
    end
  end
end
