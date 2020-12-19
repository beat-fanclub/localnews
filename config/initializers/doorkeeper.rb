Doorkeeper.configure do

  # How doorkeeper gets the current user
  resource_owner_authenticator do
    current_user || warden.authenticate!(scope: :user)
  end

  admin_authenticator do |_routes|
    current_user || warden.authenticate!(scope: :user)
  end

  default_scopes :read
  optional_scopes :write

  enforce_configured_scopes

end

