class PromotionCode < ActiveRecord::Base
  attr_accessible :code, :user_id

  belongs_to :user
  belongs_to :promotion
end
