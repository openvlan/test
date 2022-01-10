require 'rails_helper'

RSpec.describe V1::Backoffice::TripListSerializer do
  it 'serializes a trip for backoffice list' do
    [MarketplaceOrder, UserApiAddress].each do |klass|
      allow(klass).to(receive(:find).and_return(klass.new(attribute: klass.name)))
    end
    serialized_trip = described_class.new(build(:trip)).serializable_hash.as_json
    expect(
      serialized_trip
    ).to(
      match(
        'id' => nil,
        'shipper_id' => nil,
        'status' => 'broadcasting',
        'comments' => nil,
        'amount' => '0.0',
        'steps' => [
          { 'action' => 'pickup', 'marketplace_order_id' => an_instance_of(String) },
          { 'action' => 'deliver', 'marketplace_order_id' => an_instance_of(String) }
        ],
        'start_datetime' => an_instance_of(String),
        'driver_first_name' => nil,
        'driver_last_name' => nil,
        'driver_phone_number' => nil,
        'driver_last_location' => nil,
        'driver_code' => nil,
        'trip_number' => an_instance_of(Integer),
        'distance' => '0.0',
        'next_available_statuses' => %w[pending_driver_confirmation confirmed canceled],
        'milestones' => [],
        'orders_quantity' => an_instance_of(Integer)
      )
    )
  end
end
