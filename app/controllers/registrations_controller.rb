class RegistrationsController < Devise::RegistrationsController

  protected

  def update_resource(resource, params)
    if params[:email] == resource.email && params[:password].blank?
      resource.update_without_password(params.except(:email, :password, :current_password))
    else
      resource.update_with_password(params)
    end
  end
end
