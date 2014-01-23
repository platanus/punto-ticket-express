class PromotionMailer < ActionMailer::Base
  default :from => ENV['DEFAULT_EMAIL_SENDER']

  def sucessfully_codes_load promotion
    return if !promotion or !promotion.user_email
    @promotion = promotion
    mail(:to => promotion.user_email)
  end

  def failed_codes_load promotion, xls_errors
    return if !promotion or !promotion.user_email
    @promotion = promotion
    @errors = xls_errors
    mail(:to => promotion.user_email)
  end
end
