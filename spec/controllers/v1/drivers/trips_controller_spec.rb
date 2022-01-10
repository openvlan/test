require 'rails_helper'

RSpec.describe V1::Drivers::TripsController do
  describe '#take' do
    before(:each) do
      allow_any_instance_of(Shipper).to receive(:network_id) { 1 }
      allow_any_instance_of(Shipper).to receive(:set_user_role_network_id) { nil }
    end

    let(:current_user) { build(:user) }
    let(:current_shipper) { create(:shipper) }

    before(:each) do
      mock_current_user(current_user)
      allow(Shipper).to(receive(:find_by).with(user_id: current_user.id).and_return(current_shipper))
    end

    let(:marketplace_order_ids) { %w[123 234 345] }
    let(:orders) do
      marketplace_order_ids.map do |marketplace_order_id|
        create(:order, marketplace_order_id: marketplace_order_id)
      end
    end
    let(:trip) { create(:trip, orders: orders) }

    it 'takes it successfully' do
      email_sender = double(:email_sender)
      allow(Trips::Emails::Scheduled).to(receive(:new).and_return(email_sender))
      allow(email_sender).to(receive(:call))
      allow(MarketplaceOrder).to(receive(:bulk_driver_assign))
      post 'take', params: { id: trip.id }
      expect(response).to have_http_status :ok
      trip.reload
      expect(trip.status).to(eq('confirmed'))
    end

    it 'does nothing if email fails to send' do
      stub_request(:post, /sentry.io/)
      email_sender = double(:email_sender)
      allow(Trips::Emails::Scheduled).to(receive(:new).and_return(email_sender))
      error_message = 'could not send email'
      allow(email_sender).to(receive(:call).and_raise(error_message))
      post 'take', params: { id: trip.id }
      expect(response).to have_http_status :unprocessable_entity
      expect(
        JSON.parse(response.body)
      ).to(
        eq(
          'errors' => { 'error' => error_message }
        )
      )
      trip.reload
      expect(trip.status).to(eq('broadcasting'))
    end

    it 'does nothing if marketplace api request fails' do
      stub_request(:post, /sentry.io/)
      email_sender = double(:email_sender)
      allow(Trips::Emails::Scheduled).to(receive(:new).and_return(email_sender))
      allow(email_sender).to(receive(:call))
      error_message = 'another error message'
      allow(MarketplaceOrder).to(receive(:bulk_driver_assign).and_raise(error_message))
      post 'take', params: { id: trip.id }
      expect(response).to have_http_status :unprocessable_entity
      expect(JSON.parse(response.body)).to(eq('errors' => { 'error' => error_message }))
      trip.reload
      expect(trip.status).to(eq('broadcasting'))
    end
  end
end
