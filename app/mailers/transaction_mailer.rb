class TransactionMailer < ActionMailer::Base
  default :from => ENV['DEFAULT_EMAIL_SENDER']

  def completed_payment transaction, file_path, file_name
    @transaction = transaction
    attachments[file_name] = File.read(file_path) if file_path and file_name
    mail(:to => @transaction.user_email)
  end
end
