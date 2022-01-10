module V1
  class TripListSerializer < ActiveModel::Serializer
    attributes :id,
               :trip_number,
               :status,
               :comments,
               :amount,
               :steps,
               :start_datetime,
               :driver_first_name,
               :driver_last_name,
               :driver_code

    has_many :orders, serializer: V1::OrderSerializer

    def driver_first_name
      object&.shipper&.first_name
    end

    def driver_last_name
      object&.shipper&.last_name
    end

    def driver_code
      object&.shipper&.code
    end
  end
end
