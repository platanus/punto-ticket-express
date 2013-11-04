class ChangeGenderDataType < ActiveRecord::Migration
  def up
    change_column :nested_resources, :gender, :boolean
  end

  def down
    change_column :nested_resources, :gender, :integer
  end
end
