class TicketType < ActiveRecord::Base
  # attrs
  attr_accessible :event_id, :name, :price, :quantity, :event_id
  # validations
  validates_presence_of :name, :price, :quantity
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  # relationship
  belongs_to :event
  has_many :tickets

  def available_tickets_count
  	unavailable_quantity = Ticket.by_type(self.id).unavailable.sum(:quantity)
  	self.quantity - unavailable_quantity
  end
end
