module Trips
  module Emails
    class DriverIsOnTheWay
      prepend Service::Base

      def initialize(step, driver)
        @step = step
        @driver = driver
      end

      def call
        send_buyer_and_seller_emails
      end

      private

      def send_buyer_and_seller_emails
        TripMailer.driver_is_on_the_way_seller_email(@step, @driver).deliver if @step['action'].eql? 'pickup'
        TripMailer.driver_is_on_the_way_buyer_email(@step, @driver).deliver if @step['action'].eql? 'deliver'
      end
    end
  end
end
