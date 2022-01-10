module Trips
  class Complete
    prepend Service::Base

    def initialize(trip, current_user)
      @trip = trip
      @current_user = current_user
    end

    def call
      complete_trip
    end

    private

    def complete_trip
      begin
        Raven.capture do
          ActiveRecord::Base.transaction do
            @trip.finish(@current_user)
            @trip.save!
            MarketplaceOrder.bulk_deliver(
              @trip.orders.pluck(:marketplace_order_id)
            )
          end
        end
      rescue ActiveResource::TimeoutError
        # usually when this happens the request executed correctly
      rescue ActiveRecord::RecordInvalid => e
        return errors.add_multiple_errors(exception_errors(e))
      rescue StandardError => e
        errors.add(:error, e.exception)
      end
      @trip
    end
  end
end
