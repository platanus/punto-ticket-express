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
end
