class ApplicationController < ActionController::Base
  protect_from_forgery

  # redirect after sign-in
  def after_sign_in_path_for(resource)
    events_path
  end
end
