module Trips
  module Emails
    class Cancel
      prepend Service::Base

      def initialize(trip)
        @trip = trip
      end

      def call
        send_emails
      end

      private

      def send_emails
        buyer_and_seller_emails
        send_driver_email
      end

      def buyer_and_seller_emails
        @trip.steps.each do |step|
          TripMailer.seller_trip_canceled_email(step).deliver if step['action'].eql? 'pickup'
          TripMailer.buyer_trip_canceled_email(step).deliver if step['action'].eql? 'deliver'
        end
      end

      def send_driver_email
        TripMailer.driver_trip_canceled_email(@trip).deliver
      end
    end
  end
end
