class UserApiResource < ActiveResource::Base
  alias read_attribute_for_serialization send

  self.site = Rails.application.secrets.user_endpoint
  headers['Authorization'] = "Token token=#{Rails.application.secrets.user_token}"

  def self.find_by(id: nil)
    find(id)
  rescue ActiveResource::ResourceNotFound, Errno::ECONNREFUSED
    nil
  end
end
