# TODO: Validar que no se pueda pasar un evento de publicado a no publicado

class Event < ActiveRecord::Base
  # attrs
  attr_accessible :user_id, :address, :custom_url, :description, :name, :organizer_description, :organizer_name
  attr_accessible :ticket_types_attributes, :is_published, :start_time, :end_time

  # validations
  validates_presence_of :address, :description, :name, :organizer_name

  # relationship
  belongs_to :user
  has_many :ticket_types, :dependent => :destroy
  accepts_nested_attributes_for :ticket_types

  scope :published?, -> { where is_published: true }
end
