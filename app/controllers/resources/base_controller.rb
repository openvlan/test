# handles authorization and set current network of any request
require 'api_utils'

module Resources
  class BaseController < ApiUtils::BaseController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    TIKO_SERVICES_TOKENS = {
      user: Rails.application.secrets.user_token,
      marketplace: Rails.application.secrets.marketplace_token
    }.freeze

    before_action :log_route
    before_action :log_extra
    before_action :authorize_request

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    def log_extra
      Rails.logger.info(request.env.select { |k, _v| k =~ /^HTTP_/ })
    end

    def authorize_request
      authorize_service || render_unauthorized('TIKO Logistics-API - Resources')
    end

    def log_route
      Route.where(role: request.headers.fetch('TikoRole', nil) || request.headers.fetch('tikorole', nil),
                  path: "#{request.method} #{self.class.name}##{action_name}").first_or_create
    end

    def authorize_service
      authenticate_with_http_token do |token, _options|
        TIKO_SERVICES_TOKENS.value?(token)
      end
    end

    def render_unauthorized(realm = 'Application')
      headers['WWW-Authenticate'] = %(Token realm="#{realm.delete('"')}")
      render json: { message: 'Not Authorized' }, status: :unauthorized
    end

    def render_not_found
      render json: { message: 'Not found' }, status: :not_found
    end
  end
end

# handles authorization and set current network of any request
