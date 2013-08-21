class CreateProducers < ActiveRecord::Migration
  def change
    create_table :producers do |t|
      t.string :name
      t.string :rut
      t.string :address
      t.string :phone
      t.string :contact_name
      t.string :contact_email
      t.string :description
      t.string :website

      t.timestamps
    end
  end
end
