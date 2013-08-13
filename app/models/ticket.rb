class Ticket < ActiveRecord::Base
  attr_accessible :payment_type, :quantity, :ticket_type_id, :user_id
end
