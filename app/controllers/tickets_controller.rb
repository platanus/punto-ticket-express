class TicketsController < ApplicationController
	load_and_authorize_resource

  def index
    @tickets = current_user.tickets

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "ticket",
          template: "tickets/show",
          layout: "tickets/pdf",
          handlers: ["html.haml"],
          # renders html version if you set debug=true in URL
          show_as_html: params[:debug].present?
      end
    end
  end
end
