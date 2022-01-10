module V1
  module DriversApp
    class TripPaymentSerializer < ActiveModel::Serializer
      attributes :id, :payment_method, :payment_email, :confirmation_code, :paid_at
    end
  end
end
