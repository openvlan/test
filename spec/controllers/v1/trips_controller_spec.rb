require 'rails_helper'

RSpec.describe V1::TripsController do
  let(:user) { build(:user, id: 'some-id') }
  before(:each) {
    mock_current_user(user)
    allow_any_instance_of(Shipper).to receive(:set_user_role_network_id) { nil }
  }
  let(:shipper) { create(:shipper) }
  let(:marketplace_order_ids) { %w[123 234 345] }
  let(:orders) do
    marketplace_order_ids.map do |marketplace_order_id|
      create(:order, marketplace_order_id: marketplace_order_id)
    end
  end
  let(:trip) { create(:trip, orders: orders, manual: true, creator_user: user) }

  before(:each) do
    allow(shipper).to receive(:user) { double(id: '44ajk221', first_name: 'A', last_name: 'B', email: 'ab@gmail.com') }
    allow(shipper).to receive(:company) { double(company: double(network_id: 1)) }
    allow_any_instance_of(Shipper).to receive(:network_id) { 1 }
  end

  describe '#confirm_driver' do
    it 'assigns trip to shipper and transitions to confirmed' do
      expect(Trips::Emails::Scheduled).to(receive(:new).and_return(double(call: nil)))
      expect(MarketplaceOrder).to(receive(:bulk_driver_assign).with(marketplace_order_ids))

      post 'confirm_driver', params: { id: trip.id, shipper_id: shipper.id }
      expect(response).to have_http_status :ok
      expect(trip.reload.status).to(eq('confirmed'))
      expect(trip.shipper_id).to(eq(shipper.id))
    end

    it 'does nothing if email fails to send' do
      sentry_stub = stub_request(:post, /sentry.io/)
      expect(Trips::Emails::Scheduled).to(receive(:new).and_raise)
      expect(MarketplaceOrder).not_to(receive(:bulk_driver_assign))

      post 'confirm_driver', params: { id: trip.id, shipper_id: shipper.id }
      expect(response).to have_http_status :unprocessable_entity
      expect(trip.reload.status).to(eq('broadcasting'))
      expect(trip.shipper_id).to(eq(nil))
      assert_requested(sentry_stub)
    end

    it 'sends email but updates nothing if marketplace orders could not be updated' do
      sentry_stub = stub_request(:post, /sentry.io/)
      expect(Trips::Emails::Scheduled).to(receive(:new).and_return(double(call: nil)))
      expect(MarketplaceOrder).to(receive(:bulk_driver_assign).and_raise)

      post 'confirm_driver', params: { id: trip.id, shipper_id: shipper.id }
      expect(response).to have_http_status :unprocessable_entity
      expect(trip.reload.status).to(eq('broadcasting'))
      expect(trip.shipper_id).to(eq(nil))
      assert_requested(sentry_stub)
    end
  end

  describe '#start' do
    it 'does nothing if status is broadcasting' do
      sentry_stub = stub_request(:post, /sentry.io/)
      post 'start', params: { id: trip.id }
      expect(response).to have_http_status :unprocessable_entity
      expect(
        JSON.parse(response.body)
      ).to(
        eq(
          'errors' => { 'error' => "Event 'start' cannot transition from 'broadcasting'." }
        )
      )
      expect(trip.reload.status).to(eq('broadcasting'))
      assert_requested(sentry_stub)
    end

    it 'transitions trip from confirmed to ongoing' do
      expect(Trips::Emails::DriverIsOnTheWay).to(receive(:new).and_return(double(call: nil)))
      trip.confirm_driver(shipper, shipper.user)
      trip.save!
      post 'start', params: { id: trip.id }
      expect(response).to have_http_status :ok
      expect(trip.reload.status).to(eq('on_going'))
    end

    it 'does nothing if email fails to send' do
      sentry_stub = stub_request(:post, /sentry.io/)
      expect(Trips::Emails::DriverIsOnTheWay).to(receive(:new).and_raise)
      trip.confirm_driver(shipper, shipper.user)
      trip.save!
      expect(trip.status).to(eq('confirmed'))
      post 'start', params: { id: trip.id }
      expect(response).to have_http_status :unprocessable_entity
      expect(trip.reload.status).to(eq('confirmed'))
      assert_requested(sentry_stub)
    end
  end

  describe '#complete' do
    it 'does nothing if status is broadcasting' do
      sentry_stub = stub_request(:post, /sentry.io/)
      post 'complete', params: { id: trip.id }
      expect(response).to have_http_status :unprocessable_entity
      expect(
        JSON.parse(response.body)
      ).to(
        eq(
          'errors' => { 'error' => "Event 'finish' cannot transition from 'broadcasting'." }
        )
      )
      expect(trip.reload.status).to(eq('broadcasting'))
      assert_requested(sentry_stub)
    end

    it 'transitions trip from on_going to completed' do
      trip.confirm_driver(shipper, shipper.user)
      trip.start(shipper.user)
      trip.save!
      expect(trip.status).to(eq('on_going'))
      expect(MarketplaceOrder).to(receive(:bulk_deliver).with(marketplace_order_ids))
      post 'complete', params: { id: trip.id }
      expect(response).to have_http_status :ok
      expect(trip.reload.status).to(eq('completed'))
    end

    it 'does nothing if marketplace orders could not be updated' do
      sentry_stub = stub_request(:post, /sentry.io/)
      trip.confirm_driver(shipper, shipper.user)
      trip.start(shipper.user)
      trip.save!
      expect(MarketplaceOrder).to(receive(:bulk_deliver).with(marketplace_order_ids).and_raise)
      post 'complete', params: { id: trip.id }
      expect(response).to have_http_status :unprocessable_entity
      expect(trip.reload.status).to(eq('on_going'))
      assert_requested(sentry_stub)
    end
  end

  describe '#cancel' do
    def expect_send_notifications
      expect_any_instance_of(Notifications::Push).to(receive(:call))
      expect(Trips::Emails::Cancel).to(receive(:new).and_return(double(call: nil)))
    end

    def expect_not_to_send_notifications
      expect_any_instance_of(Notifications::Push).not_to(receive(:call))
      expect(Trips::Emails::Cancel).not_to(receive(:new))
    end

    it 'cancels trips in broadcasting status' do
      expect_send_notifications
      post 'cancel', params: { id: trip.id }
      expect(TripStatusChangeAudit.all.as_json.map { |audit| audit.slice('comments', 'trip_id') }).to(
        eq(
          [
            { 'comments' => "Created by #{user.email}", 'trip_id' => trip.id },
            { 'comments' => "#{user.email} marked this trip as Canceled", 'trip_id' => trip.id }
          ]
        )
      )
      expect(trip.reload.status).to(eq('canceled'))
    end

    it 'cancels trips in pending driver confirmation status' do
      trip.shipper = shipper
      trip.assign_driver
      trip.save!
      expect(trip.reload.status).to(eq('pending_driver_confirmation'))
      expect_send_notifications
      post 'cancel', params: { id: trip.id }
      expect(TripStatusChangeAudit.all.as_json.map { |audit| audit.slice('comments', 'trip_id') }).to(
        eq(
          [
            { 'comments' => "Created by #{user.email}", 'trip_id' => trip.id },
            { 'comments' => "#{user.email} marked this trip as Canceled", 'trip_id' => trip.id }
          ]
        )
      )
      expect(trip.reload.status).to(eq('canceled'))
    end

    it 'cancels trips in confirmed status' do
      trip.shipper = shipper
      trip.confirm
      trip.save!
      expect(trip.reload.status).to(eq('confirmed'))
      expect_send_notifications
      expect(MarketplaceOrder).to(receive(:bulk_driver_unassign))
      expect_any_instance_of(Trip).to(receive(:notify_cancellation_with_no_enough_time))
      post 'cancel', params: { id: trip.id }
      expect(TripStatusChangeAudit.all.as_json.map { |audit| audit.slice('comments', 'trip_id') }).to(
        eq(
          [
            { 'comments' => "Created by #{user.email}", 'trip_id' => trip.id },
            { 'comments' => "Driver #{shipper.full_name} will be doing this trip", 'trip_id' => trip.id },
            { 'comments' => "#{user.email} marked this trip as Canceled", 'trip_id' => trip.id }
          ]
        )
      )
      expect(trip.reload.status).to(eq('canceled'))
    end

    it 'gives error and changes nothing if bulk_driver_unassign request failed' do
      sentry_stub = stub_request(:post, /sentry.io/)
      trip.shipper = shipper
      trip.confirm
      trip.save!
      expect(trip.reload.status).to(eq('confirmed'))
      expect_not_to_send_notifications
      expect(MarketplaceOrder).to(receive(:bulk_driver_unassign).and_raise)
      expect_any_instance_of(Trip).not_to(receive(:notify_cancellation_with_no_enough_time))
      post 'cancel', params: { id: trip.id }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(trip.reload.status).to(eq('confirmed'))
      assert_requested(sentry_stub)
    end

    it 'cancels trips in ongoing status' do
      trip.shipper = shipper
      trip.confirm
      trip.start(user)
      trip.save!
      expect(trip.reload.status).to(eq('on_going'))
      expect_send_notifications
      expect(MarketplaceOrder).to(receive(:bulk_driver_unassign))
      expect_any_instance_of(Trip).to(receive(:notify_cancellation_with_no_enough_time))
      post 'cancel', params: { id: trip.id }
      expect(TripStatusChangeAudit.all.as_json.map { |audit| audit.slice('comments', 'trip_id') }).to(
        eq(
          [
            { 'comments' => "Created by #{user.email}", 'trip_id' => trip.id },
            { 'comments' => "Driver #{shipper.full_name} will be doing this trip", 'trip_id' => trip.id },
            { 'comments' => "#{user.email} marked this trip as started", 'trip_id' => trip.id },
            { 'comments' => "#{user.email} marked this trip as Canceled", 'trip_id' => trip.id }
          ]
        )
      )
      expect(trip.reload.status).to(eq('canceled'))
    end

    it 'fails to cancel trips in completed status' do
      sentry_stub = stub_request(:post, /sentry.io/)
      trip.shipper = shipper
      trip.confirm
      trip.start(user)
      trip.finish(user)
      trip.save!
      expect(trip.reload.status).to(eq('completed'))
      expect_not_to_send_notifications
      post 'cancel', params: { id: trip.id }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to(
        eq('errors' => { 'error' => "Event 'cancel' cannot transition from 'completed'." })
      )
      expect(trip.reload.status).to(eq('completed'))
      assert_requested(sentry_stub)
    end

    it 'fails to cancel trips in canceled status' do
      sentry_stub = stub_request(:post, /sentry.io/)
      trip.shipper = shipper
      trip.cancel(user)
      trip.save!
      expect(trip.reload.status).to(eq('canceled'))
      expect_not_to_send_notifications
      post 'cancel', params: { id: trip.id }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to(
        eq('errors' => { 'error' => "Event 'cancel' cannot transition from 'canceled'." })
      )
      assert_requested(sentry_stub)
    end

    it 'returns success and logs to sentry if email fails to send' do
      sentry_stub = stub_request(:post, /sentry.io/)
      expect(Trips::Emails::Cancel).to(receive(:new).and_raise)
      expect(trip.reload.status).to(eq('broadcasting'))
      post 'cancel', params: { id: trip.id }
      expect(response).to have_http_status(:ok)
      expect(trip.reload.status).to(eq('canceled'))
      assert_requested(sentry_stub)
    end

    it 'returns success and logs to sentry if push notification fails to send' do
      sentry_stub = stub_request(:post, /sentry.io/)
      expect_any_instance_of(Notifications::Push).to(receive(:call).and_raise)
      expect(Trips::Emails::Cancel).to(receive(:new).and_return(double(call: nil)))
      expect(trip.reload.status).to(eq('broadcasting'))
      post 'cancel', params: { id: trip.id }
      expect(response).to have_http_status(:ok)
      expect(trip.reload.status).to(eq('canceled'))
      assert_requested(sentry_stub)
    end
  end
end
