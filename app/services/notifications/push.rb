module Notifications
  class Push
    def initialize(trip, edition = false) # rubocop:todo Style/OptionalBooleanParameter
      @user_notifier = Notifications::Notifier.new
      @notification_builder = Notifications::TripNotificationBuilder.new(trip, edition)
    end

    def call
      @user_notifier.notify(builder: @notification_builder)
    end
  end
end
