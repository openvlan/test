FactoryBot.define do
  factory :license do
    number { 'AAA000' }
    state { Faker::Address.state }
    expiration_date { DateTime.now }
    photos { [Rack::Test::UploadedFile.new("#{Rails.root}/spec/assets/tiko_logo.png")] }

    shipper
  end
end
