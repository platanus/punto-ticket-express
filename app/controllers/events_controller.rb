require 'chronic'

class EventsController < ApplicationController
  load_and_authorize_resource

  # GET /events/1
  # GET /events/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end
end
