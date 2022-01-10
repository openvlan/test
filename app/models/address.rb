class Address < ApplicationRecord
  audited associated_with: :company

  belongs_to :company, optional: true
  audited associated_with: :company

  ATTRIBUTES = %i[id
                  street_1
                  street_2
                  zip_code
                  city
                  state
                  country
                  notes
                  gps_coordinates
                  formatted_address
                  _destroy].freeze


  before_validation :assign_closest_network, if: :gps_coordinates_changed?

  private

  def assign_closest_network
    closest_network = Network.closest(gps_coordinates)
    if network_id.present? && closest_network&.id != network_id
      errors.add(:network_id, 'cannot change')
    elsif closest_network.present?
      self.network_id = closest_network.id
    else
      errors.add(:network_id, 'There is no network for current location')
    end
  end
end