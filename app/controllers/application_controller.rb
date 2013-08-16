class ApplicationController < ActionController::Base
  # Devise authentication
  before_filter :authenticate_user!
  before_filter :authorize_admin

  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :flash => { :error => exception.message }
  end

  # redirect after sign-in
  def after_sign_in_path_for(resource)

    if current_user.nil? or current_user.participant?
      root_path

    elsif current_user.organizer?
      events_path

    elsif current_user.admin?
      admin_root_path

    else
      root_path
    end
  end

  def authorize_admin
    if !current_user.admin? and self.class.to_s.split("::").first == "Admin"
      raise CanCan::AccessDenied.new
    end rescue nil
  end
end
