class OrderWithUserApiDecorator < SimpleDelegator
  def initialize(order, warehouses)
    super(order)
    @warehouses = warehouses
  end

  def trip_type
    if warehouse['location_type'].downcase == 'port'.freeze
      TripType::DRAYAGE
    else
      needs_cooling ? TripType::LTL_REFRIGERATED : TripType::LTL
    end
  end

  def warehouse
    @warehouses[warehouse_address_id]
  end
end
