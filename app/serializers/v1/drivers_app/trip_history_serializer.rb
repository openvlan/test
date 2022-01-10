module V1
  module DriversApp
    class TripHistorySerializer < ActiveModel::Serializer
      attributes :id, :amount, :status, :trip_number, :start_datetime

      has_one :trip_payment, serializer: V1::DriversApp::TripPaymentSerializer
    end
  end
end
