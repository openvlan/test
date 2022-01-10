class TripPaymentSerializer < ActiveModel::Serializer
  attributes :id,
             :trip,
             :payment_method,
             :payment_email,
             :confirmation_code,
             :created_at,
             :updated_at

  def trip
    V1::Backoffice::TripRootFieldSerializer.new(object.trip)
  end
end
