class TransactionMailer < ActionMailer::Base
  default :from => ENV['DEFAULT_EMAIL_SENDER']

  def completed_payment transaction
    @transaction = transaction
    mail(:to => @transaction.user_email)
  end
end
