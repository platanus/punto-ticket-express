class CreateProducersUsers < ActiveRecord::Migration
  def change
    create_table :producers_users do |t|
      t.belongs_to :user
      t.belongs_to :producer
    end
  end
end
