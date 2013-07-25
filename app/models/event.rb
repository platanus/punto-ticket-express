class Event < ActiveRecord::Base
  attr_accessible :user_id, :address, :custom_url, :description, :name, :organizer_description, :organizer_name

  belongs_to :user
end
