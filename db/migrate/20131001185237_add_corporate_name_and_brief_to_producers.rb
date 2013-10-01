class AddCorporateNameAndBriefToProducers < ActiveRecord::Migration
  def change
    add_column :producers, :corporate_name, :string
    add_column :producers, :brief, :text
  end
end
