require 'google_maps_service'

# Setup global parameters
GoogleMapsService.configure do |config|
  config.key = Rails.application.secrets.gmap_api_key
  config.retry_timeout = 20
  config.queries_per_second = 10
end
