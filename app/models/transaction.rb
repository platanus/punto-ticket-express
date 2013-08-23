class Transaction < ActiveRecord::Base
  attr_accessible :amount, :details, :payment_status, :token, :transaction_time, :user_id
end
