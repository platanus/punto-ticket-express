class TicketType < ActiveRecord::Base
  # attrs
  attr_accessible :event_id, :name, :price, :quantity, :event_id
  # validations
  validates_presence_of :name, :price, :quantity
  # relationship
  belongs_to :event
  has_many :tickets
end
