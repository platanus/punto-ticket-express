class HomeController < ApplicationController
  skip_filter :authenticate_user!

  def index
    @events = Event.published.not_expired.order(:start_time)
  end
end

