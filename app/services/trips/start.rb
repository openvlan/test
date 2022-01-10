module Trips
  class Start
    prepend Service::Base

    def initialize(trip, current_user)
      @trip = trip
      @current_user = current_user
    end

    def call
      start_trip
    end

    private

    def start_trip
      handle_errors do
        @trip.start(@current_user)
        @trip.save!
        Trips::Emails::DriverIsOnTheWay.new(@trip.steps.first, @trip.shipper).call
        @trip
      end
    end

    def handle_errors(&block)
      Raven.capture do
        ActiveRecord::Base.transaction(&block)
      end
    rescue ActiveRecord::RecordInvalid => e
      errors.add_multiple_errors(exception_errors(e))
    rescue StandardError => e
      errors.add(:error, e.exception)
    end
  end
end
