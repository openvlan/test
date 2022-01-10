FactoryBot.define do
  factory :company do
    address
    mc_number_type { %i[no MC FF MX].sample }
  end
end
