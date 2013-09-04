class CreateNestedResources < ActiveRecord::Migration
  def change
    create_table :nested_resources do |t|
      t.string :name
      t.string :last_name
      t.string :email
      t.string :rut
      t.string :phone
      t.string :mobile_phone
      t.string :address
      t.string :company
      t.string :job
      t.string :job_address
      t.string :job_phone
      t.string :website
      t.integer :gender
      t.date :birthday
      t.integer :age
      t.integer :nestable_id
      t.string :nestable_type

      t.timestamps
    end
  end
end
