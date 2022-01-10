Rails.application.configure do
  config.after_initialize do
    Bullet.enable        = ENV.fetch('BULLET_ENABLE', false)
    Bullet.bullet_logger = true
    Bullet.raise         = true # raise an error if n+1 query occurs
  end
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.seconds.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  ActionMailer::Base.smtp_settings = {
    :user_name => Rails.application.secrets.notification_email_username,
    :password => Rails.application.secrets.notification_email_password,
    :domain => Rails.application.secrets.notification_email_domain,
    :address => Rails.application.secrets.notification_email_address,
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  REDIS_DB = Rails.application.secrets.redis_db
  REDIS_HOST = Rails.application.secrets.redis_host
  REDIS_PORT = Rails.application.secrets.redis_port
  REDIS_URL  = "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}".freeze
  config.cache_store = :redis_store, REDIS_URL, { expires_in: 90.minutes }
end
