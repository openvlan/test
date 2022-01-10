class V1::LicenseSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id, :number, :state, :expiration_date, :photos

  def photos
    return unless object.photos.attached?

    ActiveModelSerializers::SerializableResource.new(
      object.photos.order(position: :asc),
      each_serializer: V1::PhotoSerializer
    ).as_json[:photos]
  end
end
