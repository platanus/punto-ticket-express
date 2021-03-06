class TicketsController < ApplicationController
	load_and_authorize_resource except: [:nested_resource, :download]

  def index
    @tickets = current_user.tickets

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def nested_resource
    @ticket = Ticket.find(params[:id])
    authorize! :read, @ticket
    @nested_resource = @ticket.nested_resource
    @event = @ticket.event
    render :template => "nested_resources/show"
  end

  def download
    if params.has_key? :ticket_id
      @tickets = Ticket.find_all_by_id(params[:ticket_id])
    else
      @tickets = Ticket.find(params[:ticket_ids])
    end

    authorize! :download, @tickets

    respond_to do |format|
      format.pdf do
        render pdf: "ticket",
          template: "tickets/pdf",
          layout: "tickets/pdf",
          handlers: ["erb"],
          # renders html version if you set debug=true in URL
          show_as_html: params[:debug].present?
      end
    end
  end
end
