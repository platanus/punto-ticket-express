class HomeController < ApplicationController
  skip_filter :authenticate_user!

  def index
    @events = Event.published?
  end
end
