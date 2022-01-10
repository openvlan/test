class V1::DriversMeSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  type :driver

  attributes :id,
             :last_name,
             :first_name,
             :full_name,
             :birth_date,
             :gender,
             :created_at,
             :status,
             :user,
             :working_hours,
             :vehicle,
             :license,
             :company

  def vehicle
    return if object&.vehicle.nil?

    ActiveModelSerializers::SerializableResource.new(
      object&.vehicle,
      { serializer: V1::VehicleSerializer }
    ).as_json[:vehicle]
  end

  def license
    return if object&.license.nil?

    ActiveModelSerializers::SerializableResource.new(
      object&.license,
      { serializer: V1::LicenseSerializer }
    ).as_json[:license]
  end

  def company
    return if object&.company.nil?

    ActiveModelSerializers::SerializableResource.new(
      object&.company,
      { serializer: V1::CompanySerializer }
    ).as_json[:company]
  end

  def full_name
    object&.full_name
  end

  def user
    User.find_by(id: object&.user_id)
  end
end
