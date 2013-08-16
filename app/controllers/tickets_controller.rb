class TicketsController < InheritedResources::Base
  def update
    update! do |success, failure|
      success.html do 
        TicketMailer.completed_payment(@ticket).deliver
        redirect_to ticket_url(@ticket)
      end

      failure.html { redirect_to tickets_url }
    end
  end
end
