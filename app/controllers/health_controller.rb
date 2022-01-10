# health checked. avoid.
# rubocop:disable all
require 'api_utils'

class HealthController < ApiUtils::BaseController
  VERSION = '1.10.0'.freeze
  SECRET_TOKEN = 'btMgvZqgrdzjl90X1aoQS0R28iU2GI2b' # rubocop:todo Style/MutableConstant

  def health
    status = 500 unless healthy?
    status = 200 if healthy?

    result = {
      message: 'Something is wrong',
      version: VERSION,
      build_number: Rails.application.secrets.build_number,
      commit_sha: Rails.application.secrets.commit_sha
    }

    result = {
      message: 'Ready',
      version: VERSION,
      build_number: Rails.application.secrets.build_number,
      commit_sha: Rails.application.secrets.commit_sha
    } if healthy?

    render json: result, status: status
  end

  def sentry
    raise ActionController::RoutingError, 'Not Found' unless params[:token] == SECRET_TOKEN

    raise "Sentry test: a random error #{rand(1..10_000)}"
  end

  def ping_async
    Rails.logger.info '[PingAsync] - Starting async ping ...'
    Scheduler::Provider.logistic_scheduler.ping_async
    Rails.logger.info '[PingAsync] - Async ping success ...'
    render plain: 'OK', status: :ok
  rescue StandardError => e
    Rails.logger.info "[PingAsync] - Async ping error... #{e}"
    render plain: 'ERROR', status: :internal_server_error
  end

  private

  def healthy?
    @is_healthy ||= db_connection_alive? && redis_alive?
  end

  def redis_alive?
    r = Redis.new(host: Rails.application.secrets.redis_host, port: Rails.application.secrets.redis_port)
    r.ping
  rescue Errno::ECONNREFUSED => e
    false
  rescue Redis::CannotConnectError => e
    false
  end

  def db_connection_alive?
    ActiveRecord::Base.establish_connection # Establishes connection
    ActiveRecord::Base.connection # Calls connection object

    true
  rescue StandardError
    false
  end
end
