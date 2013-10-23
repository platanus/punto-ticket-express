class Promotion < ActiveRecord::Base
  attr_accessible :activation_code, :end_date, :limit, :name, :promotion_type, :promotion_type_config, :start_date, :ticket_type_id

  validates_presence_of :name, :promotion_type, :ticket_type_id, :promotion_type_config

  belongs_to :ticket_type
  has_one :event, through: :ticket_type
  has_many :tickets
  has_many :transactions, through: :tickets, uniq: true
end
