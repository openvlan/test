module Resources
  class OrderSerializer < ActiveModel::Serializer
    attributes :id,
               :marketplace_order_id,
               :delivery_location_id,
               :warehouse_address_id,
               :delivery_cost,
               :delivery_distance,
               :total_weight_in_lb,
               :created_at,
               :updated_at,
               :trip,
               :driver,
               :vehicle,
               :type_of_trip

    def type_of_trip
      object.trip_type
    end

    def trip
      object&.trips&.last
    end

    def driver
      return if object.shipper.nil?

      ActiveModelSerializers::SerializableResource.new(
        object.shipper,
        { serializer: Resources::DriverSerializer }
      ).as_json[:shipper]
    end

    def vehicle
      return if object.shipper.nil?

      object.shipper.vehicle
    end
  end
end
