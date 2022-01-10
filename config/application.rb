require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_cable/engine"
require 'rails/all'
require 'active_storage'
# require 'active_storage/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LogisticsApi
  class ActiveRecord::Base
    cattr_accessor :skip_callbacks
  end

  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.time_zone = 'Eastern Time (US & Canada)'

    # In order to eager load stuff in the lib folder
    config.eager_load_paths << Rails.root.join('lib')

    # In order to load all the locales tree
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml')]

    # In order to use by default the id: :uuid when using the generators
    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
    end

    # Do not automatically include the all the helpers on the controllers
    config.action_controller.include_all_helpers = false

    puts '*' * 100
    puts Rails.env
    puts '*' * 100

    Raven.configure do |config|
      config.dsn = Rails.application.secrets.sentry_dsn
      config.current_environment = Rails.application.secrets.env_name
    end

    # Set Active Storage service.
    config.active_storage.service = Rails.application.secrets.storage_service.try(:to_sym)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.middleware.use Rack::Deflater

    config.middleware.use Rack::Attack if Rails.env.production?

  end
end
