class V1::VehicleSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id, :truck_type, :year, :make, :model, :color, :license_plate,
             :gross_vehicle_weight_rating, :insurance_provider,
             :has_liftgate, :has_forklift, :photos

  def photos
    return unless object.photos.attached?

    ActiveModelSerializers::SerializableResource.new(
      object.photos.order(position: :asc),
      each_serializer: V1::PhotoSerializer
    ).as_json[:photos]
  end
end
