class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :address
      t.text :description
      t.string :organizer_name
      t.text :organizer_description
      t.string :custom_url

      t.timestamps
    end
  end
end
