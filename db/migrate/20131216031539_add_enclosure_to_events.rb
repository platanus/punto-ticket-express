class AddEnclosureToEvents < ActiveRecord::Migration
  def change
    add_column :events, :enclosure, :string
  end
end
