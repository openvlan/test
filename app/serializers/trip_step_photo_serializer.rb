class TripStepPhotoSerializer < ActiveModel::Serializer
  attributes :id,
             :trip_id,
             :shipper,
             :file,
             :step_index,
             :gps_coordinates,
             :created_at,
             :updated_at

  def shipper
    Simple::ShipperSerializer.new(object.shipper).as_json
  end

  def file
    V1::PhotoSerializer.new(object.file).as_json
  end
end
