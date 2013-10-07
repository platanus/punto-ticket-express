class RemoveOrganizerNameAndOrganizerDescriptionFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :organizer_name
    remove_column :events, :organizer_description
  end

  def down
    add_column :events, :organizer_name, :string
    add_column :events, :organizer_description, :text
  end
end
