FactoryBot.define do
  factory :shipper do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gateway_id { Faker::Number.number(digits: 10) }
    user_id { 'e0ed4771-a731-4ada-9c6f-c95aaff5c581' }
    provided_services { [Shipper::ProvidedServices::DRAYAGE, Shipper::ProvidedServices::LTL] }
    network_id { 1 }

    trait :with_vehicle do
      after(:create) do |shipper, _evaluator|
        create(:vehicle, shipper: shipper)
      end
    end

    factory :shipper_with_vehicle, traits: [:with_vehicle]

    factory :authenticated_shipper do
      with_vehicle
      token_expire_at { 24.hours.from_now.to_i }
    end
  end
end
