module Services
  class NotificationsService < HttpUsersService
    RESOURCE = 'notifications'.freeze
    ENDPOINT = "#{SERVICE_BASE_URL}/#{RESOURCE}" # rubocop:todo Style/MutableConstant

    def dispatch(body:)
      response = HTTParty.post(ENDPOINT, headers: HEADERS, body: body)
      response.code.to_s != '200'
    end
  end
end
