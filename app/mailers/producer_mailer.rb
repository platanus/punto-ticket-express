class ProducerMailer < ActionMailer::Base
  default :from => ENV['DEFAULT_EMAIL_SENDER']

  def confirmed_producer producer, user
    return if !producer or !user or !user.email
    @producer = producer
    mail(:to => user.email)
  end

  def created_producer producer
    return if !producer
    @producer = producer
    mail(:to => User.admins.pluck(:email))
  end
end
