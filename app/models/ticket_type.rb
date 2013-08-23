class TicketType < ActiveRecord::Base
  # attrs
  attr_accessible :event_id, :name, :price, :quantity, :event_id

  # validations
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  # relationship
  belongs_to :event
  has_many :tickets

  def available_tickets_count
  	unavailable_quantity = Ticket.by_type(self.id).processing.count
    unavailable_quantity += Ticket.by_type(self.id).completed.count
  	self.quantity - unavailable_quantity
  end
end
