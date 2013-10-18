class CreateGlobalConfigurationInstance < ActiveRecord::Migration
  def up
    GlobalConfiguration.delete_all
    GlobalConfiguration.create({fixed_fee: 0, percent_fee: 0})
  end

  def down
    GlobalConfiguration.delete_all
  end
end
