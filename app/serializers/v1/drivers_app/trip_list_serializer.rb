module V1
  module DriversApp
    class TripListSerializer < ActiveModel::Serializer
      attributes :id, :amount, :status, :shipper_id, :start_datetime,
                 :origin, :last_stop, :total_weight_in_lb, :needs_cooling, :distance, :trip_number

      def needs_cooling
        object&.orders.each do |order| # rubocop:todo Lint/SafeNavigationChain
          return true if order.needs_cooling?
        end

        false
      end

      def origin
        order_id = object.steps.first['marketplace_order_id']
        order = Order.find_by(marketplace_order_id: order_id).warehouse_address_id
        UserApiAddress.find_by(id: order)
      end

      def last_stop
        order_id = object.steps.last['marketplace_order_id']
        order = Order.find_by(marketplace_order_id: order_id).delivery_location_id
        UserApiAddress.find_by(id: order)
      end
    end
  end
end
