class HomeController < ApplicationController
  skip_filter :authenticate_user!

  def index
    @events = Event.published(true).with_valid_date(true).order(:start_time)
  end
end
