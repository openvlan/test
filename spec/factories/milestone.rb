FactoryBot.define do
  factory :milestone do
    trip
    name { Faker::Name.first_name }
    comments { Faker::Lorem.sentence }
    gps_coordinates { "POINT(#{Faker::Address.longitude} #{Faker::Address.latitude})" }
  end
end
