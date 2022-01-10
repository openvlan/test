module Requests
  module JsonHelper
    def json
      @json_response ||= JSON.parse(response.body, symbolize_names: true) # rubocop:todo Naming/MemoizedInstanceVariableName
    end
  end

  module AuthHelpers
    def auth_headers(_user)
      auth_token = AuthorizeUser.call('dummy_header', {}).result
      {
        Authorization: "Bearer #{auth_token}"
      }
    end

    def shipper_auth_headers(shipper)
      auth_token = ShipperApi::AuthenticateShipper.call(shipper.email, shipper.password).result
      {
        Authorization: "Bearer #{auth_token}"
      }
    end

    def resource_authentication_headers
      {
        Authorization: "Token token=#{Services::BaseController::NILUS_SERVICES_TOKENS.values.sample}"
      }
    end

    def services_auth_headers(token)
      {
        Authorization: "Token token=#{token}"
      }
    end
  end

  module HeadersHelpers
    def set_accept_header(version: 1) # rubocop:todo Naming/AccessorMethodName
      Rack::MockRequest::DEFAULT_ENV['HTTP_ACCEPT'] = "application/vnd.api-nilus+json; version=#{version}"
    end

    def remove_accept_header
      Rack::MockRequest::DEFAULT_ENV.delete('HTTP_ACCEPT')
    end
  end
end

RSpec.configure do |config|
  config.include Requests::JsonHelper,  type: :request
  config.include Requests::AuthHelpers, type: :request
  config.include Requests::HeadersHelpers, type: :routing

  config.before :all, type: :routing do
    silence_warnings do
      Rack::MockRequest::DEFAULT_ENV = Rack::MockRequest::DEFAULT_ENV.dup
    end
  end

  config.after :all, type: :routing do
    remove_accept_header
  end
end
