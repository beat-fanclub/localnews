class ApplicationController < ActionController::Base
  check_authorization unless: :devise_controller?
  before_action :devise_user_params, if:  :devise_controller?

  before_action :set_action_cable_identifier

  protected

  def devise_user_params
    CUSTOM_USER_FIELDS = %i[name avatar].freeze
    devise_parameter_sanitizer.permit(:sign_up, keys: CUSTOM_USER_FIELDS)
    devise_parameter_sanitizer.permit(:account_update, keys: CUSTOM_USER_FIELDS)
  end

  private

  def set_action_cable_identifier
    cookies.encrypted[:session_id] = session.id.to_s
    cookies.encrypted[:user_id] = current_user&.id
  end
end
