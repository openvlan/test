module Trips
  module Emails
    class OrderDelivered
      prepend Service::Base

      def initialize(marketplace_order_id)
        @marketplace_order_id = marketplace_order_id
      end

      def call
        send_buyer_and_seller_emails
      end

      private

      def send_buyer_and_seller_emails
        TripMailer.order_delivered_buyer_email(@marketplace_order_id).deliver
        TripMailer.order_delivered_seller_email(@marketplace_order_id).deliver
      end
    end
  end
end
