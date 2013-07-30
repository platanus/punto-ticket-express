class Event < ActiveRecord::Base

  # attrs
  attr_accessible :user_id, :address, :custom_url, :description, :name, :organizer_description, :organizer_name, :start, :end, :ticket_types_attributes
  # attrs non persistent
  attr_accessible :start_date, :start_time, :end_date, :end_time
  # getters & setters
  attr_accessor :start_date, :start_time, :end_date, :end_time
  # validations
  validates_presence_of :address, :custom_url, :description, :name, :organizer_name
  # relationship
  belongs_to :user
  has_many :ticket_types, :dependent => :destroy
  accepts_nested_attributes_for :ticket_types

end
