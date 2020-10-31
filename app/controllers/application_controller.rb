class ApplicationController < ActionController::Base
  check_authorization unless: :devise_controller?
  before_action :devise_user_params, if:  :devise_controller?

  protected

  def devise_user_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
