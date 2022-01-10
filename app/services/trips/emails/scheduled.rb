module Trips
  module Emails
    class Scheduled
      prepend Service::Base

      def initialize(trip, start_date, driver)
        @trip = trip
        @start_date = start_date
        @driver = driver
      end

      def call
        send_buyer_and_seller_emails
      end

      private

      def send_buyer_and_seller_emails
        @trip.steps.each do |step|
          TripMailer.seller_trip_scheduled_email(step, @start_date, @driver).deliver if step['action'].eql? 'pickup'
          TripMailer.buyer_trip_scheduled_email(step, @start_date, @driver).deliver if step['action'].eql? 'deliver'
        end
      end
    end
  end
end
