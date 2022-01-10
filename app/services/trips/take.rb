module Trips
  class Take
    prepend Service::Base

    def initialize(trip, shipper, current_user)
      @trip = trip
      @shipper = shipper
      @current_user = current_user
    end

    def call
      take_trip
    end

    private

    def take_trip
      handle_errors do
        @trip.confirm_driver(@shipper, @current_user)
        @trip.save!
        Trips::Emails::Scheduled.new(@trip, @trip.start_datetime, @shipper).call
        MarketplaceOrder.bulk_driver_assign(
          @trip.orders.pluck(:marketplace_order_id)
        )
        @trip
      end
    end

    def handle_errors(&block)
      Raven.capture do
        ActiveRecord::Base.transaction(&block)
      end
    rescue ActiveResource::TimeoutError
      # usually when this happens the request executed correctly
    rescue AASM::InvalidTransition
      errors.add(:status, 'TRIP_ALREADY_TAKEN')
    rescue ActiveRecord::RecordInvalid => e
      errors.add_multiple_errors(exception_errors(e))
    rescue StandardError => e
      errors.add(:error, e.exception)
    end
  end
end
