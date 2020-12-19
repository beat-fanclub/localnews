Apipie.configure do |config|
  config.app_name                = "Localnews"
  config.api_base_url            = ""
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"

  config.default_locale = 'en'
  config.languages = ['en']
  config.locale = lambda { |*| nil }
end
