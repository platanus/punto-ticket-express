class TicketType < ActiveRecord::Base
  attr_accessible :event_id, :name, :price, :quantity

  belongs_to :event
end
