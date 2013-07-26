# TODO: Validar que no se pueda pasar un evento de publicado a no publicado

class Event < ActiveRecord::Base
  attr_accessible :user_id, :address, :custom_url, :description, :name, :organizer_description, :organizer_name
  attr_accessible :ticket_types_attributes, :is_published

  belongs_to :user
  has_many :ticket_types

  accepts_nested_attributes_for :ticket_types

  # CALLBACKS
end
