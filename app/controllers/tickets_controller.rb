class TicketsController < InheritedResources::Base
	load_and_authorize_resource

  def create
    create! do |success, failure|
      success.html do 
        TicketMailer.completed_payment(@ticket).deliver
        redirect_to ticket_url(@ticket)
      end

      failure.html { redirect_to tickets_url }
    end
  end

  def show
    super do |format|
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

  protected
    def collection
      @tickets = current_user.tickets
    end

end
