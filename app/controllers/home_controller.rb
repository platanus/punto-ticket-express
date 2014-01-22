class HomeController < ApplicationController
  skip_filter :authenticate_user!

  def index
    @events = Event.on_sale.in_publish_range.order(:start_time)
  end
end

