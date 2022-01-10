class UserApiAddress < UserApiResource
  self.element_name = :address

  def self.find_all(delivery_location_ids)
    delivery_location_ids.empty? ? [] : get(:find_all, delivery_location_ids: delivery_location_ids)
  end
end
