module Notifications
  class TripNotificationBuilder
    def initialize(trip, edition = false) # rubocop:todo Style/OptionalBooleanParameter
      @trip = trip
      @edition = edition
    end

    def build
      notification = {
        notification: {
          title: 'TIKO Drivers',
          body: message(@trip.status),
          receiver_ids: shipper_ids
        },
        service: 'driver'
      }

      if Rails.env.development?
        puts '🔥🔥🔥 Send notification 🔥🔥🔥'
        puts notification.as_json
      end

      notification
    end

    private

    def message(state)
      return I18n.t('push.notification.messages.edition', id: @trip.trip_number) if @edition

      message_hash[state]
    end

    def message_hash
      {
        pending_driver_confirmation: I18n.t("push.notification.messages.#{@trip.status}"),
        broadcasting: I18n.t("push.notification.messages.#{@trip.status}"),
        canceled: I18n.t("push.notification.messages.#{@trip.status}", id: @trip.trip_number)
      }.with_indifferent_access
    end

    def shipper_ids
      shippers = Shipper.filter_active_by_trip @trip

      return shippers.map(&:user_id).uniq if @trip.broadcasting?

      return [@trip.shipper.user_id] if @trip.shipper

      []
    end
  end
end
