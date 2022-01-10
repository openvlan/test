require 'rails_helper'

RSpec.describe License, type: :model do
  let(:license_to_test) { create(:license) }

  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_presence_of(:expiration_date) }

  before(:each) do
    allow_any_instance_of(Shipper).to receive(:set_user_role_network_id) { nil }
  end

  it 'has a valid factory' do
    expect do
      create(:license).validate!
    end.not_to(raise_error)
  end

  it 'is not valid without a license number' do
    license_to_test.number = nil
    expect(license_to_test).to_not be_valid
  end

  it 'is not valid with a license number that contains spaces' do
    license_to_test.number = 'INVALID LICENCE THAT CONTAINS SPACES'
    expect(license_to_test).to_not be_valid
  end

  it 'is not valid with a license number that contains special characters' do
    license_to_test.number = "!@\#$%^&*()_"
    expect(license_to_test).to_not be_valid
  end

  it 'is valid with numbers, letters, hypens and asterisks' do
    license_to_test.number = 'WA-LKECR577DU*'
    expect(license_to_test).to be_valid
  end

  it 'is valid without photos' do
    expect do
      create(:license, photos: []).validate!
    end.not_to(raise_error)
  end
end
