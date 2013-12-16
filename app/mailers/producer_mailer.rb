class ProducerMailer < ActionMailer::Base
  default :from => ENV['DEFAULT_EMAIL_SENDER']

  def confirmed_producer producer, user
    return if !producer or !user or !user.email
    @producer = producer
    mail(:to => user.email)
  end
end
