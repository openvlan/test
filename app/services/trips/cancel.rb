module Trips
  class Cancel
    prepend Service::Base

    def initialize(trip, current_user)
      @trip = trip
      @current_user = current_user
    end

    def call
      cancel_trip
    end

    private

    def cancel_trip
      begin
        Raven.capture do
          @trip.cancel(@current_user)
          @trip.save!
        end
      rescue ActiveRecord::RecordInvalid => e
        errors.add_multiple_errors(exception_errors(e))
      rescue StandardError => e
        errors.add(:error, e.exception)
      end

      if errors.empty?
        send_notifications
        @trip
      else
        errors
      end
    end

    def send_notifications
      Raven.capture do
        Trips::Emails::Cancel.new(@trip).call
        Notifications::Push.new(@trip).call
      end
    rescue StandardError
      # Ignored
    end
  end
end
