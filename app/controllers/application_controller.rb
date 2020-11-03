class ApplicationController < ActionController::Base
  check_authorization unless: :devise_controller?
  before_action :devise_user_params, if:  :devise_controller?

  before_action :set_action_cable_identifier

  protected

  def devise_user_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  def set_action_cable_identifier
    cookies.encrypted[:session_id] = session.id.to_s
    cookies.encrypted[:user_id] = current_user&.id
  end
end
