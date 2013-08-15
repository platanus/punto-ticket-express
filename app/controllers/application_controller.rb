class ApplicationController < ActionController::Base
  # Devise authentication
  before_filter :authenticate_user!

  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :flash => { :error => exception.message }
  end

  # redirect after sign-in
  def after_sign_in_path_for(resource)
    events_path
  end
end
