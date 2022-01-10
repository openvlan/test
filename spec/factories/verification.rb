FactoryBot.define do
  VEHICLE_VERIFICATIONS = { # rubocop:todo Lint/ConstantDefinitionInBlock
    license_plate: {
      register_date: Faker::Date.between(from: 5.years.ago, to: 1.year.ago),
      number: "#{Faker::Name.initials(number: 3)}#{Faker::Number.number(digits: 3)}",
      state: 'Buenos Aires',
      city: 'AR'
    }
  }.with_indifferent_access.freeze

  factory :verification do
    expire { Faker::Boolean.boolean }
    expire_at { expire ? Faker::Time.forward(days: 365) : nil }

    VEHICLE_VERIFICATIONS.each do |type, information|
      trait type.to_s.to_sym do
        type { type }
        information { information }
      end
      factory "#{type}_verification".to_sym, traits: [type.to_s.to_sym]
    end
  end
end
