class V1::DriversTableSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id,
             :full_name,
             :company_name,
             :city,
             :state,
             :created_at,
             :truck_type,
             :gross_vehicle_weight_rating,
             :status,
             :provided_services,
             :code

  def full_name
    "#{object&.first_name} #{object&.last_name}"
  end

  def code
    object.code
  end

  def company_name
    object&.company&.name
  end

  def city
    object&.company&.address&.city
  end

  def state
    object&.company&.address&.state
  end

  def truck_type
    object&.vehicle&.truck_type
  end

  def gross_vehicle_weight_rating
    object&.vehicle&.gross_vehicle_weight_rating
  end

  def status
    object&.status.humanize # rubocop:todo Lint/SafeNavigationChain
  end
end
