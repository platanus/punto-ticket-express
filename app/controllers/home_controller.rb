class HomeController < ApplicationController
  skip_filter :authenticate_user!

  def index
    @events = Event.published.with_valid_date.order(:start_time)
  end
end
