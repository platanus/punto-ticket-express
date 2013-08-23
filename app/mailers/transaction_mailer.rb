class TransactionMailer < ActionMailer::Base
  default from: "no-reply@puntoticketexpress.com"

  def completed_payment transaction
    @transaction = transaction
    mail(:to => @transaction.user_email)
  end
end
