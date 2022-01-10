Rails.application.configure do
  config.after_initialize do
    Bullet.enable        = true
    Bullet.alert         = true
    Bullet.bullet_logger = true
    Bullet.console       = true
  # Bullet.growl         = true
    Bullet.rails_logger  = true
    Bullet.add_footer    = true
  end
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.action_mailer.perform_caching = false

  TIKO_NOTIFICATION_EMAIL = Rails.application.secrets.tiko_notification_email
  
  config.action_mailer.default_options = { from: TIKO_NOTIFICATION_EMAIL }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              Rails.application.secrets.smtp_address,
    port:                 Rails.application.secrets.smtp_port,
    domain:               Rails.application.secrets.smtp_domain,
    user_name:            Rails.application.secrets.smtp_user_name,
    password:             Rails.application.secrets.smtp_password,
    authentication:       Rails.application.secrets.smtp_authentication,
    enable_starttls_auto: true
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker


  config.log_tags = [
    :request_id,
    ->(req) { req.headers.fetch('X-Client-Version', 'No version') }
  ]

  redis_connection = "redis://#{ ENV.fetch("REDIS_HOST", '192.168.99.100') }:#{ ENV.fetch("REDIS_PORT", '6379') }/0/cache"
  config.cache_store = :redis_store, redis_connection, { expires_in: 90.minutes }
end
