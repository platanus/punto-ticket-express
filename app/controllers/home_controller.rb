class HomeController < ApplicationController
  skip_filter :authenticate_user!

  def index
    @events = Event.on_sale.order(:start_time)
  end
end

