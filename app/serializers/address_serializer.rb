class AddressSerializer < ActiveModel::Serializer
  type :address

  attributes :id,
             :latlng,
             :street_1, # rubocop:todo Naming/VariableNumber
             :street_2, # rubocop:todo Naming/VariableNumber
             :zip_code,
             :city,
             :state,
             :country,
             :contact_name,
             :contact_cellphone,
             :contact_email,
             :telephone,
             :open_hours,
             :notes,
             :gps_coordinates
end
