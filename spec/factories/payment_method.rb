FactoryBot.define do
  factory :payment_method do
    shipper
    payment_method { PaymentMethod::ACH }
  end
end
