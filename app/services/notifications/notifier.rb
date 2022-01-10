module Notifications
  class Notifier
    def initialize(dispatcher: Services::NotificationsService.new)
      @dispatcher = dispatcher
    end

    def notify(builder:)
      body = builder.build
      @dispatcher.dispatch(body: body)
    end
  end
end
