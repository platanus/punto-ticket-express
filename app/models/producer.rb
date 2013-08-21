class Producer < ActiveRecord::Base
  attr_accessible :address, :contact_email, :contact_name, :description, :name, :phone, :rut, :website

  has_and_belongs_to_many :users
  has_many :events
end
