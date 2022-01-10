source 'https://rubygems.org'

ruby '2.6.8'

gem 'aasm', '~> 5.2'
gem 'active_model_serializers', '~> 0.10.0'
gem 'activerecord-postgis-adapter'
gem 'activeresource', '~> 5.0'
gem 'api-utils', git: 'git@github.com:tikoglobal/api-utils.git', ref: '01c6ce16d2'
gem 'audited', '~> 4.9'
gem 'aws-sdk-s3', '~> 1.96.1'
gem 'bcrypt' # Ruby binding for the OpenBSD bcrypt() password hashing algorithm
gem 'cancancan'
gem 'discard', '~> 1.0' # Soft deletes for ActiveRecord done right.
gem 'dry-types' # Is a simple and extendable type system for Ruby; useful for value coercions, applying constraints and other stuff
gem 'fast_jsonapi'
gem 'haml-rails', '~> 2.0'
gem 'httparty'
gem 'jwt', '~> 2.2.3'
gem 'kaminari', '~> 1.2.1'
gem 'memory_profiler'
gem 'mercadopago-sdk', '~> 1.3.0'
gem 'oj', '~> 3.11.6'
gem 'pagy', '~> 3.13' # For paginating results that outperforms the others in each and every benchmark and comparison.
gem 'paypal-sdk-rest'
gem 'pg' # The PostgreSQL Adapter
gem 'puma', '< 6'
gem 'pushme-aws', git: 'https://github.com/nilusorg/pushme-aws', branch: :master # Push notifications through AWS SNS Mobile Push Notification Service
gem 'rack-attack' # Rack middleware for blocking & throttling
gem 'rack-cors', require: 'rack/cors'
gem 'rack-mini-profiler', '~> 2.3.2'
gem 'rails', '~> 5.2.6'
gem 'redis-namespace'
gem 'redis-rails'
gem 'rgeo-geojson'
gem 'role_model'
gem 'sendgrid-ruby'
gem 'sentry-raven'
gem 'sidekiq'
gem 'timezone', '~> 1.0'
gem 'typhoeus' # In order to make HTTP Requests
gem 'whenever', require: false
gem 'xlsxtream' # In order to be able to export and stream XLSX files

gem 'google_maps_service'

# This is important to be here at the bottom
gem 'api-pagination' # For pagination info in your headers, not in your response body.
gem 'querifier'

gem 'dotenv-rails'
gem 'tzinfo-data'

group :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'annotate'
  gem 'bullet', '5.7.5'
  gem 'byebug', '11.0', platform: :mri
  gem 'faker'
  gem 'rspec-rails', '~> 5.0.1'
  gem 'rubocop', '~> 1.12.1'
  gem 'rubocop-faker', require: false
  gem 'rubocop-rails', require: false
end

group :cypress do
  gem 'cypress-on-rails', '~> 1.5'
end

group :development do
  gem 'debase', '~> 0.2.4.1'
  gem 'ruby-debug-ide', '~> 0.7.0'

  gem 'guard-rspec', require: false

  gem 'httplog', require: false

  gem 'listen', '~> 3.0.5'

  gem 'rails-erd', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 5.2.0'
  gem 'json-schema'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-sidekiq'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'simplecov-json', require: false
  gem 'webmock', '~> 3.13'
end
