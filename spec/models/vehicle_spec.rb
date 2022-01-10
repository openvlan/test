require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  it { is_expected.to belong_to(:shipper) }
  it { is_expected.to have_many(:verifications) }

  it { expect(subject.class).to be_const_defined(:VERIFICATIONS) }

  before(:each) do
    allow_any_instance_of(Shipper).to receive(:set_user_role_network_id) { nil }
  end

  it 'has a valid factory' do
    expect do
      create(:vehicle).validate!
    end.not_to(raise_error)
  end

  it 'requires truck type' do
    expect do
      create(:vehicle, truck_type: nil).validate!
    end.to(
      raise_error(
        ActiveRecord::RecordInvalid,
        "Validation failed: Truck type can't be blank"
      )
    )
  end

  it 'requires gross vehicle weight rating' do
    expect do
      create(:vehicle, gross_vehicle_weight_rating: nil).validate!
    end.to(
      raise_error(
        ActiveRecord::RecordInvalid,
        "Validation failed: Gross vehicle weight rating can't be blank"
      )
    )
  end

  it 'is valid without photos' do
    expect do
      create(:vehicle, photos: []).validate!
    end.not_to(raise_error)
  end

  it 'is valid without year' do
    expect do
      create(:vehicle, year: nil).validate!
    end.not_to(raise_error)
  end

  it 'is valid without license plate' do
    expect do
      create(:vehicle, license_plate: nil).validate!
    end.not_to(raise_error)
  end
end
