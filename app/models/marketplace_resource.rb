class MarketplaceResource < ActiveResource::Base
  alias read_attribute_for_serialization send

  self.site = Rails.application.secrets.marketplace_endpoint
  headers['Authorization'] = "Token token=#{Rails.application.secrets.marketplace_token}"
end
