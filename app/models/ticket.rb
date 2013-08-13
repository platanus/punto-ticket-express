class Ticket < ActiveRecord::Base
  attr_accessible :payment_status, :quantity, :ticket_type_id, :user_id

  belongs_to :ticket_type
  belongs_to :user
end
