module Services
  class UserService < Services::Base
    service_path Rails.application.secrets.user_endpoint
    headers Authorization: "Token token=#{Rails.application.secrets.user_token}"

    def read_attribute_for_serialization(attr)
      send(attr)
    end
  end
end
