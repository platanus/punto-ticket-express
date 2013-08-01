class HomeController < ApplicationController
  def index
    @events = Event.where :is_published => true
  end
end
