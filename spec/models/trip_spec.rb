require 'rails_helper'

RSpec.describe Trip, type: :model do
  context 'with shipper' do
    it { is_expected.to belong_to(:shipper) }
    it { is_expected.to have_many(:milestones) }
    it { is_expected.to respond_to(:pickup_window).with(0).argument }
    it { is_expected.to respond_to(:dropoff_window).with(0).argument }
    it { is_expected.to respond_to(:net_income).with(0).argument }
  end

  before(:each) do
    allow_any_instance_of(Shipper).to receive(:set_user_role_network_id) { nil }
  end

  context 'instance with' do
    context 'deliveries' do
      let(:deliveries) { create_list(:delivery_with_packages, 3) }
      let(:deliveries_amount) { deliveries.sum(&:total_amount) }

      subject { create(:trip, deliveries: deliveries, amount: (deliveries_amount + 50)) }

      skip { expect(subject.net_income).to eq(50) }
    end
  end

  context 'assign to a driver' do
    let(:trip_assigned) { build(:trip_with_shipper) }
    before do
      allow_any_instance_of(Shipper).to receive(:network_id) { 1 }
      stub_external_messages(trip_assigned)
      trip_assigned.save!
    end

    it 'change status to confirmed' do
      expect(trip_assigned.confirmed?).to eq(true)
    end

    context 'when another driver is already assigned' do
      let(:another_driver) { create(:shipper, user_id: 'aaaabbbb-a731-4ada-9c6f-c95aaff5c581') }
      it 'raise a trip already taken error' do
        trip_assigned.shipper = another_driver
        expect do
          trip_assigned.confirm
        end.to(
          raise_error(AASM::InvalidTransition)
        )
      end
    end
  end

  context 'driver cancel trip' do
    let(:trip_assigned) { build(:trip_with_shipper, start_datetime: Time.parse('2021-07-20')) }
    let(:another_driver) { create(:shipper, user_id: 'aaaabbbb-a731-4ada-9c6f-c95aaff5c581') }

    before do
      allow_any_instance_of(Shipper).to receive(:network_id) { 1 }
      allow_any_instance_of(StartDatetimeValidator).to receive(:validate).and_return(true)
      allow_any_instance_of(TripReschedule).to receive(:notice_cancellation_with_enough_time).and_return(nil)
      allow(trip_assigned).to receive(:unassign_driver_orders).and_return(nil)
      allow(trip_assigned).to receive(:notify_cancellation_with_no_enough_time).and_return(nil)
      allow(trip_assigned).to receive(:notify_driver_trip_refused).and_return(nil)
      allow(trip_assigned.shipper).to receive(:user) {
        double({ id: trip_assigned.shipper.user_id,
                 full_name: "#{trip_assigned.shipper.first_name} #{trip_assigned.shipper.last_name}",
                 email: 'as@mail.com' })
      }

      allow(another_driver).to receive(:user) {
        double({ id: another_driver.user_id,
                 full_name: "#{another_driver.first_name} #{another_driver.last_name}",
                 email: 'as2@mail.com' })
      }
      stub_external_messages(trip_assigned)
      trip_assigned.save!
    end

    it 'fails if driver is not current trip shipper assigned' do
      expect do
        trip_assigned.cancel_by_driver(another_driver)
      end.to(
        raise_error(Trip::DriverIsNotCurrentlyAssignedException)
      )
    end

    context 'in enough time' do
      before do
        allow_any_instance_of(Shipper).to receive(:network_id) { 1 }
        allow(TripEnoughTime).to receive_messages(enough?: true)
        trip_assigned.cancel_by_driver(trip_assigned.shipper)
        trip_assigned.save!
      end

      it 'change status to cancelled ' do
        expect(trip_assigned.canceled?).to eq(true)
      end

      it 'create a new one' do
        last_trip = Trip.order(created_at: :desc).first
        expect(last_trip.id != trip_assigned.id).to eq(true)
        expect(last_trip.created_at).to be > trip_assigned.created_at
        expect(last_trip.start_datetime).to eq(trip_assigned.start_datetime + 24.hours)
        expect(last_trip.broadcasting?).to eq(true)
        expect(last_trip.distance).to eq(trip_assigned.distance)
        expect(last_trip.orders.count).to eq(trip_assigned.orders.count)
        expect(last_trip.orders.map(&:id)).to eq(trip_assigned.orders.map(&:id))
        expect(last_trip.steps).to eq(trip_assigned.steps)
        expect(last_trip.shipper).to eq(nil)
        expect(last_trip.gateway).to eq(trip_assigned.gateway)
        expect(last_trip.gateway_id).to eq(trip_assigned.gateway_id)
        expect(last_trip.gateway_data).to eq(trip_assigned.gateway_data)
        expect(last_trip.trip_number != trip_assigned.trip_number).to eq(true)
      end
    end

    context 'in not enough time' do
      before do
        allow(TripEnoughTime).to receive_messages(enough?: false)
        trip_assigned.cancel_by_driver(trip_assigned.shipper)
        trip_assigned.save!
      end

      it 'should set to canceled' do
        expect(trip_assigned.canceled?).to eq(true)
      end
    end
  end

  context 'status transitions log' do
    let(:shipper) { create(:shipper) }

    #
    # Between "()" I put a transition number defined in the documentation (https://tiko-global.atlassian.net/wiki/spaces/TG/pages/1601994753/Trip+status+graph+release+v1.13)
    # eze
    #
    before(:each) do
      allow_any_instance_of(Shipper).to receive(:network_id) { 1 }
      allow_any_instance_of(StartDatetimeValidator).to receive(:validate).and_return(true)
      allow_any_instance_of(TripReschedule).to receive(:notice_cancellation_with_enough_time).and_return(nil)
      allow_any_instance_of(Trip).to(receive(:save_address))
      allow_any_instance_of(Trip).to receive(:orders_network_id) { 1 }
      allow_any_instance_of(Trip).to receive(:orders_network_consistency) { true }
      allow_any_instance_of(Trip).to(receive(:calculate_distance)).and_return(123)
      allow(shipper).to receive(:user) {
                          double({ id: shipper.user_id,
                                   full_name: "#{shipper.first_name} #{shipper.last_name}",
                                   email: 'as@mail.com' })
                        }
    end

    it '(1) manual creation: init in broadcasting' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      expect(trip.broadcasting?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(1)
      expect(trip.trip_status_change_audits.last.status).to eq('broadcasting')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip created')
      expect(trip.trip_status_change_audits.last.comments).to eq('Created by jp@mail.com')
    end

    it '(5) manual creation with shipper: init in pending_driver_confirmation' do
      trip = Trip.build_manually(build(:trip).attributes.merge(
                                   creator_user: double(full_name: 'jose perez', email: 'tikoemployee@mail.com'),
                                   shipper_id: shipper.id
                                 ))
      stub_external_messages(trip)
      trip.save!
      expect(trip.pending_driver_confirmation?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(1)
      expect(trip.trip_status_change_audits.last.status).to eq('pending_driver_confirmation')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip awaiting driver confirmation')
      msg = "tikoemployee@mail.com created this trip and manually assigned it to driver #{shipper.full_name}"
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(1b) manual creation: init in broadcasting' do
      trip = Trip.new(build(:trip).attributes.merge(creator_user: double(full_name: 'jose perez'),
                                                    old_trip_number: 123))
      trip.save!
      expect(trip.broadcasting?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(1)
      expect(trip.trip_status_change_audits.last.status).to eq('broadcasting')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip created')
      expect(trip.trip_status_change_audits.last.comments).to eq('Created automatically because trip #123 was canceled')
    end

    it '(2) confirm: from broadcasting to confirmed' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      expect(trip.broadcasting?).to eq(true)

      trip.confirm_driver(shipper, shipper.user)

      expect(trip.confirmed?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(2)
      expect(trip.trip_status_change_audits.last.status).to eq('confirmed')
      expect(trip.trip_status_change_audits.last.event).to eq('Driver confirmed')
      expect(trip.trip_status_change_audits.last.comments).to eq("Driver #{shipper.full_name} will be doing this trip")
    end

    it '(6) confirm: from pending_driver_confirmation to confirmed by driver through app' do
      trip = Trip.build_manually(build(:trip).attributes.merge(
                                   creator_user: double(full_name: 'jose perez', email: 'tikoemployee@mail.com'),
                                   shipper_id: shipper.id
                                 ))
      stub_external_messages(trip)
      trip.save!
      expect(trip.pending_driver_confirmation?).to eq(true)

      trip.confirm_driver(shipper, shipper.user)

      expect(trip.confirmed?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(2)
      expect(trip.trip_status_change_audits.last.status).to eq('confirmed')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip confirmed')
      msg = "Driver #{shipper.full_name} accepted the trip using the app"
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(6) confirm: from pending_driver_confirmation to confirmed by tiko employee' do
      allow(shipper).to receive(:user) {
                          double(id: 'uasdf123', full_name: 'jose perez', email: 'tikoemployee@mail.com')
                        }
      trip = Trip.build_manually(build(:trip).attributes.merge(
                                   creator_user: double(full_name: 'jose perez', email: 'tikoemployee@mail.com'),
                                   shipper_id: shipper.id
                                 ))
      stub_external_messages(trip)
      trip.save!
      expect(trip.pending_driver_confirmation?).to eq(true)

      trip.confirm_driver(shipper, shipper.user)

      expect(trip.confirmed?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(2)
      expect(trip.trip_status_change_audits.last.status).to eq('confirmed')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip confirmed')
      msg = 'tikoemployee@mail.com marked this trip as Confirmed'
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(3) ongoing: from confirmed to on_going (by driver)' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      trip.confirm_driver(shipper, shipper.user)
      expect(trip.confirmed?).to eq(true)

      trip.start(shipper.user)

      expect(trip.on_going?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(3)
      expect(trip.trip_status_change_audits.last.status).to eq('on_going')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip started')
      msg = "Driver #{shipper.full_name} started the trip using the app"
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(3) ongoing: from confirmed to on_going (by tiko employee)' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      expect(trip.broadcasting?).to eq(true)
      trip.confirm_driver(shipper, shipper.user)
      expect(trip.confirmed?).to eq(true)

      trip.start(double(id: 'uuid123123', full_name: 'jose perez', email: 'tikoemployee@mail.com'))

      expect(trip.on_going?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(3)
      expect(trip.trip_status_change_audits.last.status).to eq('on_going')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip started')
      msg = 'tikoemployee@mail.com marked this trip as started'
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(4) complete: from on_going to finish (by driver)' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      trip.confirm_driver(shipper, shipper.user)
      trip.start(double(id: 'uuid123123', full_name: 'jose perez', email: 'tikoemployee@mail.com'))
      expect(trip.on_going?).to eq(true)

      trip.finish(shipper.user)

      expect(trip.completed?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(4)
      expect(trip.trip_status_change_audits.last.status).to eq('completed')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip completed')
      msg = "Driver #{shipper.full_name} indicated that he did the last delivery of this trip using the app"
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(4) complete: from on_going to finish (by tiko employee)' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      trip.confirm_driver(shipper, shipper.user)
      trip.start(double(id: 'uuid123123', full_name: 'jose perez', email: 'tikoemployee@mail.com'))
      expect(trip.on_going?).to eq(true)

      trip.finish(double(id: 'uuid123123', full_name: 'jose perez', email: 'tikoemployee@mail.com'))

      expect(trip.completed?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(4)
      expect(trip.trip_status_change_audits.last.status).to eq('completed')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip completed')
      msg = 'tikoemployee@mail.com marked this trip as Complete'
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(9) cancel: from broadcasting to cancelled' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      expect(trip.broadcasting?).to eq(true)

      trip.cancel(double(id: 'uuid123123', full_name: 'jose perez', email: 'tikoemployee@mail.com'))

      expect(trip.canceled?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(2)
      expect(trip.trip_status_change_audits.last.status).to eq('canceled')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip canceled')
      msg = 'tikoemployee@mail.com marked this trip as Canceled'
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(10) cancel: from pending_driver_confirmation to cancelled' do
      trip = Trip.build_manually(build(:trip).attributes.merge(
                                   creator_user: double(full_name: 'jose perez', email: 'tikoemployee@mail.com'),
                                   shipper_id: shipper.id
                                 ))
      stub_external_messages(trip)
      trip.save!
      expect(trip.pending_driver_confirmation?).to eq(true)

      trip.cancel(double(id: 'uuid123123', full_name: 'jose perez', email: 'tikoemployee@mail.com'))

      expect(trip.canceled?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(2)
      expect(trip.trip_status_change_audits.last.status).to eq('canceled')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip canceled')
      msg = 'tikoemployee@mail.com marked this trip as Canceled'
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(19) cancel: from pending_driver_confirmation to cancelled (driver)' do
      trip = Trip.build_manually(build(:trip).attributes.merge(
                                   creator_user: double(full_name: 'jose perez', email: 'tikoemployee@mail.com'),
                                   shipper_id: shipper.id
                                 ))
      stub_external_messages(trip)
      trip.save!
      expect(trip.pending_driver_confirmation?).to eq(true)
      expect(trip).to(receive(:notify_driver_trip_refused))

      trip.cancel(shipper.user)

      expect(trip.canceled?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(2)
      expect(trip.trip_status_change_audits.last.status).to eq('canceled')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip refused by driver')
      msg = "Driver #{shipper.full_name} refused the trip using the app"
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(19 bis) cancel: from pending_driver_confirmation to cancelled (driver)' do
      trip = Trip.build_manually(build(:trip).attributes.merge(
                                   creator_user: double(full_name: 'jose perez', email: 'tikoemployee@mail.com'),
                                   shipper_id: shipper.id
                                 ))
      stub_external_messages(trip)
      trip.save!
      expect(trip.pending_driver_confirmation?).to eq(true)
      expect(trip).to(receive(:notify_driver_trip_refused))

      trip.cancel_by_driver(shipper, nil)

      expect(trip.canceled?).to eq(true)
      expect(trip.trip_status_change_audits.count).to eq(2)
      expect(trip.trip_status_change_audits.last.status).to eq('canceled')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip refused by driver')
      msg = "Driver #{shipper.full_name} refused the trip using the app"
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(7) cancel: from confirmed to canceled (driver)' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      trip.confirm_driver(shipper, shipper.user)
      expect(trip.confirmed?).to eq(true)

      allow(trip).to receive(:close_procedure) { nil }
      trip.cancel_by_driver(shipper)

      expect(trip.trip_status_change_audits.count).to eq(3)
      expect(trip.trip_status_change_audits.last.status).to eq('canceled')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip canceled')
      msg = "Driver #{shipper.full_name} canceled the trip using the app"
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(7 bis) cancel: from confirmed to canceled (driver)' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      trip.confirm_driver(shipper, shipper.user)
      expect(trip.confirmed?).to eq(true)

      allow(trip).to receive(:close_procedure) { nil }
      allow(trip).to receive(:unassign_driver_orders) { nil }
      trip.cancel(shipper.user)

      expect(trip.trip_status_change_audits.count).to eq(3)
      expect(trip.trip_status_change_audits.last.status).to eq('canceled')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip canceled')
      msg = "Driver #{shipper.full_name} canceled the trip using the app"
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it '(8) cancel: from confirmed to canceled (tiko employee)' do
      user_double = double(full_name: 'jose perez', email: 'jp@mail.com')
      trip = Trip.build_manually(build(:trip).attributes.merge(creator_user: user_double))
      trip.save!
      trip.confirm_driver(shipper, shipper.user)
      expect(trip.confirmed?).to eq(true)

      allow(trip).to receive(:close_procedure) { nil }
      allow(trip).to receive(:unassign_driver_orders) { nil }
      trip.cancel(double(id: 'uuid123123', full_name: 'jose perez', email: 'tikoemployee@mail.com'))

      expect(trip.trip_status_change_audits.count).to eq(3)
      expect(trip.trip_status_change_audits.last.status).to eq('canceled')
      expect(trip.trip_status_change_audits.last.event).to eq('Trip canceled')
      msg = 'tikoemployee@mail.com marked this trip as Canceled'
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end
  end
end

def stub_external_messages(trip)
  allow(UserApiAddress).to(
    receive(:find).and_return(
      UserApiAddress.new(open_hours: { 'weekend' => [],
                                       'workweek' => ['tuesday'],
                                       'to_weekend' => '',
                                       'to_workweek' => 23,
                                       'from_weekend' => '',
                                       'from_workweek' => 2 })
    )
  )

  allow(UserApiAddress).to(
    receive(:find_by).and_return(nil)
  )

  allow(trip).to receive_messages(calculate_distance: 1000)
end
