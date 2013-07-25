class Event < ActiveRecord::Base
  attr_accessible :address, :custom_url, :description, :name, :organizer_description, :organizer_name
end
