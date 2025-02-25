require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Localnews
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.search_languages = [ :simple, :english, :dutch, :french ]

    config.action_mailer.default_url_options = { host: 'nieuws.naamloze.website' }

    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      html_tag
    end

  end
end
