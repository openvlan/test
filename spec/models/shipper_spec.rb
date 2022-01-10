require 'rails_helper'

RSpec.describe Shipper, type: :model do
  it { is_expected.to have_many(:milestones).through(:trips) }
  it { is_expected.to have_many(:trips) }
  it { is_expected.to have_many(:verifications) }
  skip { is_expected.to have_many(:vehicles) }

  skip { is_expected.to validate_presence_of(:first_name) }
  skip { is_expected.to validate_presence_of(:email) }
  skip { is_expected.to validate_presence_of(:password) }

  it { expect(subject.class).to be_const_defined(:DEFAULT_REQUIREMENT_TEMPLATE) }
  it { expect(subject.class).to be_const_defined(:REQUIREMENTS) }
  it { expect(subject.class).to be_const_defined(:MINIMUM_REQUIREMENTS) }
  it { expect(subject.class::REQUIREMENTS).to contain_exactly('habilitation_transport_food', 'sanitary_notepad') }
  it {
    expect(subject.class::MINIMUM_REQUIREMENTS).to contain_exactly('driving_license', 'is_monotributista',
                                                                   # rubocop:todo Layout/LineLength
                                                                   'has_cuit_or_cuil', 'has_banking_account', 'has_paypal_account')
    # rubocop:enable Layout/LineLength
  }

  it { is_expected.to respond_to(:full_name).with(0).argument }
  skip { is_expected.to respond_to(:name).with(0).argument }
  it { is_expected.to respond_to(:has_device?).with(0..1).argument }
  it { is_expected.to respond_to(:requirements).with(0).argument }
  it { is_expected.to respond_to(:minimum_requirements).with(0).argument }

  before(:each) do
    allow_any_instance_of(Shipper).to receive(:set_user_role_network_id) { nil }
  end

  it 'needs provided_services' do
    [nil, [], ''].each do |blank_value|
      expect do
        expect(build(:shipper, provided_services: blank_value).validate!)
      end.to(raise_error("Validation failed: Provided services can't be blank"))
    end
  end

  it 'can provide drayage service' do
    expect do
      expect(build(:shipper, provided_services: [Shipper::ProvidedServices::DRAYAGE]).validate!)
    end.not_to(raise_error)
  end

  it 'can provide ltl service' do
    expect do
      expect(build(:shipper, provided_services: [Shipper::ProvidedServices::LTL]).validate!)
    end.not_to(raise_error)
  end

  it 'can provide both drayage and ltl service' do
    expect do
      expect(
        build(
          :shipper,
          provided_services: [Shipper::ProvidedServices::DRAYAGE, Shipper::ProvidedServices::LTL]
        ).validate!
      )
    end.not_to(raise_error)
  end

  it 'can not provide any other service' do
    expect do
      expect(build(:shipper, provided_services: [Shipper::ProvidedServices::LTL, 'another_service']).validate!)
    end.to(raise_error('Validation failed: Provided services is not included in the list'))
  end

  it 'has network as its company' do
    allow_any_instance_of(Address).to receive(:assign_closest_network) { nil }
    allow_any_instance_of(Address).to receive(:network_id) { 1 }
    company = create(:company)
    shipper = create(:shipper, company: company)
    expect(shipper.network_id).to eq(company.network_id)
  end
end
