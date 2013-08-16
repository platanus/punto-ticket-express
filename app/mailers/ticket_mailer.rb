class TicketMailer < ActionMailer::Base
  default from: "no-reply@pte.com"

  def completed_payment ticket
  	mail(:to => ticket.user_email, :subject => "Pago procesado")
  end  
end
