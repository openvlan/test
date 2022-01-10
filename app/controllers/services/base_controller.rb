# base controller which has autorization and authentication methods
require 'api_utils'

module Services
  class BaseController < ApiUtils::BaseController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    TIKO_SERVICES_TOKENS = {
      user: Rails.application.secrets.user_token,
      marketplace: Rails.application.secrets.marketplace_token
    }.freeze

    before_action :authorize_request
    before_action :log_route

    private

    def authorize_request
      authorize_service || render_unauthorized('TIKO Logistics-API - Resources')
    end

    def authorize_service
      authenticate_with_http_token do |token, _options|
        TIKO_SERVICES_TOKENS.values.include?(token)
      end
    end

    def log_route
      Route.where(role: request.headers.fetch('TikoRole', nil) || request.headers.fetch('tikorole', nil),
                  path: "#{request.method} #{self.class.name}##{action_name}").first_or_create
    end

    def render_unauthorized(realm = 'Application')
      headers['WWW-Authenticate'] = %(Token realm="#{realm.gsub(/"/, '')}")
      render json: { message: 'Not Authorized' }, status: :unauthorized
    end
  end
end
