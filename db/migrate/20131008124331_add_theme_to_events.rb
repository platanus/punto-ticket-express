class AddThemeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :theme, :string
  end
end
