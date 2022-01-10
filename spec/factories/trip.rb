FactoryBot.define do
  factory :trip do
    before(:build, :create) do
      allow_any_instance_of(StartDatetimeValidator).to receive(:validate).and_return(true)
      allow_any_instance_of(Trip).to(receive(:save_address))
      allow_any_instance_of(Trip).to(receive(:calculate_distance)).and_return(123)
    end

    timezone_name { 'America/New_York' }
    trip_number { Faker::Number.number(digits: 10) }
    orders { [create(:order, marketplace_order_id: Faker::Number.number(digits: 10))] }

    transient do
      pickup_schedule {
        {
          start: Faker::Time.forward(days: 1, period: :morning),
          end: Faker::Time.forward(days: 1, period: :evening)
        }
      }
      dropoff_schedule {
        {
          start: Faker::Time.forward(days: 1, period: :morning),
          end: Faker::Time.forward(days: 2, period: :evening)
        }
      }
    end
    start_datetime { Time.parse('2021-01-01') }
    steps do
      steps_temp = []
      orders.each do |o|
        steps_temp << { action: 'pickup', marketplace_order_id: o.marketplace_order_id }
        steps_temp << { action: 'deliver', marketplace_order_id: o.marketplace_order_id }
      end
      steps_temp
    end

    trait :assigned do
      status { 'waiting_shipper' }

      after(:create) do |trip, _evaluator|
        create(:trip_assignment, trip: trip, state: 'assigned')
      end
    end

    trait :confirmed do
      status { 'confirmed' }
    end

    trait :with_shipper do
      shipper
    end

    trait :created_some_weeks_ago do
      transient do
        number_of_weeks { 1 }
      end

      created_at { number_of_weeks.weeks.ago }
    end

    factory :trip_assigned, traits: [:assigned]
    factory :trip_with_shipper, traits: %i[with_shipper confirmed]
  end
end
