class TicketMailer < ActionMailer::Base
  add_template_helper(TicketTypesHelper)
  default from: "no-reply@puntoticketexpress.com"

  def completed_payment ticket
    @ticket = ticket
    mail(:to => @ticket.user_email)
  end  
end
