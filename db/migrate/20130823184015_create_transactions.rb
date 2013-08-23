class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :token
      t.belongs_to :user
      t.string :payment_status
      t.decimal :amount
      t.datetime :transaction_time
      t.string :details

      t.timestamps
    end
  end
end
