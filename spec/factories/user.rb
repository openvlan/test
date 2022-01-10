FactoryBot.define do
  factory :user do
    username do
      Faker::Internet.user_name
    end
    email { Faker::Internet.free_email }
    password { Faker::Internet.password }
    roles { [{ name: 'admin' }, { name: 'seller' }, { name: 'buyer' }, { name: 'driver' }] }
    active { true }
    phone { nil }
    code { 777 }

    trait :with_profile do
      after(:create) do |user, _evaluator|
        create(:profile, user: user)
      end
    end

    trait :authenticated do
      token_expire_at { 24.hours.from_now.to_i }
    end

    factory :user_with_profile, traits: [:with_profile]
    factory :authenticated_user, traits: %i[with_profile authenticated]
  end
end
