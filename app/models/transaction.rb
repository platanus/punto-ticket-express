class Transaction < ActiveRecord::Base
 # attrs
  attr_accessible :amount, :details, :payment_status, :token, :transaction_time, :user_id

  # relationship
  belongs_to :user
  has_many :tickets

  #delegates
  delegate :email, to: :user, prefix: true, allow_nil: true
end
