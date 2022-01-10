FactoryBot.define do
  factory :trip_payment do
    trip
    payment_method { PaymentMethod::ACH }
  end
end
