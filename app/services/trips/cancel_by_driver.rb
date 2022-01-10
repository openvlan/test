module Trips
  class CancelByDriver
    prepend Service::Base

    def initialize(trip, driver, reason)
      @trip = trip
      @driver = driver
      @reason = reason
    end

    def call
      cancel_trip
    end

    private

    def cancel_trip
      begin
        Raven.capture do
          @trip.cancel_by_driver(@driver, @reason)
          @trip.save!
        end
      rescue Trip::DriverIsNotCurrentlyAssignedException => e
        errors.add(Trip::DriverIsNotCurrentlyAssignedException.sym, e.message)
      rescue ActiveRecord::RecordInvalid => e
        return errors.add_multiple_errors(exception_errors(e))
      rescue StandardError => e
        errors.add(:error, e.exception)
      end

      @trip
    end
  end
end
