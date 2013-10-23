class Promotion < ActiveRecord::Base
  attr_accessible :activation_code, :end_date, :limit, :name, :promotion_type, :promotion_type_config, :start_date, :ticket_type_id

  has_and_belongs_to_many :transactions
  belongs_to :ticket_type
end
