module V1
  module Backoffice
    class TripListSerializer < ActiveModel::Serializer
      attributes :id,
                 :status,
                 :comments,
                 :amount,
                 :steps,
                 :start_datetime,
                 :shipper_id,
                 :driver_first_name,
                 :driver_last_name,
                 :driver_phone_number,
                 :driver_last_location,
                 :driver_code,
                 :trip_number,
                 :distance,
                 :next_available_statuses,
                 :orders_quantity

      has_many :milestones

      def orders_quantity
        object.orders.count
      end

      def driver_first_name
        object&.shipper&.first_name
      end

      def driver_last_name
        object&.shipper&.last_name
      end

      def driver_phone_number
        object&.shipper&.phone_num
      end

      def driver_code
        object&.shipper&.code
      end

      def driver_last_location
        object.shipper&.last_location
      end

      def next_available_statuses
        object.aasm.states(permitted: true).map(&:name)
      end
    end
  end
end
