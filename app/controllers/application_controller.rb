require 'api_utils'

class ApplicationController < ApiUtils::BaseController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActionController::MimeResponds
  include ::ActionController::Cookies
  include PagingStuff

  before_action :authorize_request
  before_action :set_raven_context
  before_action :log_route
  around_action :transactions_filter

  def transactions_filter(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def audited_user
    current_user.id
  end

  Audited.current_user_method = :audited_user

  def current_user
    @current_user || authorize_user
  end

  private

  def set_raven_context
    Raven.user_context(id: current_user.try(:id))
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def log_route
    Route.where(role: request.headers.fetch('TikoRole', nil) || request.headers.fetch('tikorole', nil),
                path: "#{request.method} #{self.class.name}##{action_name}").first_or_create
  end

  def authorize_request
    authorize_user || render_unauthorized('TIKO - Logistics API')
  end

  def authorize_user_without_roles
    authenticate_with_http_token do |token, _options|
      @current_user ||= AuthorizeUser.call(token, request, false).result # rubocop:todo Naming/MemoizedInstanceVariableName
    end
  end

  def authorize_user
    return @current_user ||= AuthorizeUser.call(cookies[:auth], request).result unless cookies[:auth].nil?

    authenticate_with_http_token do |token, _options|
      @current_user ||= AuthorizeUser.call(token, request).result
    end
  end

  def render_unauthorized(realm = 'Application')
    headers['WWW-Authenticate'] = %(Token realm="#{realm.gsub(/"/, '')}")
    render json: { message: 'Not Authorized' }, status: :unauthorized
  end
end
