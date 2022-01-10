module V1
  class TripPlannerSerializer < ActiveModel::Serializer
    attributes  :id,
                :created_at,
                :needs_cooling,
                :total_weight_in_lb,
                :warehouse,
                :delivery_location,
                :delivery_distance,
                :marketplace_order_id,
                :pallets,
                :no_palletized_items_quantity,
                :type_of_trip

    def marketplace_orders(marketplace_order_id)
      @instance_options[:marketplace_orders][marketplace_order_id]
    end

    def delivery_locations(delivery_location_id)
      @instance_options[:delivery_locations][delivery_location_id]
    end

    def needs_cooling
      object.needs_cooling
    end

    def delivery_distance
      object.delivery_distance
    end

    def pallets
      marketplace_order = marketplace_orders(object.marketplace_order_id)
      marketplace_order['pallets']
    end

    def no_palletized_items_quantity
      marketplace_order = marketplace_orders(object.marketplace_order_id)
      marketplace_order['no_palletized_items_quantity']
    end

    def warehouse
      object.warehouse
    end

    def type_of_trip
      object.trip_type
    end

    def delivery_location
      delivery_locations(object.delivery_location_id)
    end
  end
end
