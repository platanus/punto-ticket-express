class AddNestedResourceSourceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :nested_resource_source, :string
  end
end
