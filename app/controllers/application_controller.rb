
CUSTOM_USER_FIELDS = %i[name avatar].freeze

class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?
  check_authorization unless: :devise_controller?
  before_action :devise_user_params, if:  :devise_controller?

  before_action :set_action_cable_identifier

  protected

  def devise_user_params
    devise_parameter_sanitizer.permit(:sign_up, keys: CUSTOM_USER_FIELDS)
    devise_parameter_sanitizer.permit(:account_update, keys: CUSTOM_USER_FIELDS)
  end

  private

  def set_action_cable_identifier
    cookies.encrypted[:session_id] = session.id.to_s
    cookies.encrypted[:user_id] = current_user&.id
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an 
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? 
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end
end
