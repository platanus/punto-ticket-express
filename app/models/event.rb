class Event < ActiveRecord::Base
  attr_accessible :user_id, :address, :custom_url, :description, :name, :organizer_description, :organizer_name, :ticket_types_attributes

  belongs_to :user
  has_many :ticket_types

  accepts_nested_attributes_for :ticket_types
end
