module Shippers
  module Emails
    class Status
      def initialize(driver)
        @driver = driver
        @user = User.find(driver.user_id)
      end

      def call
        send_email
      end

      private

      def send_email
        return errors.add(:user, I18n.t('services.status_emails.no_driver', id: @driver.user_id)) unless @user.email

        DriverMailer.driver_rejected_email(@user).deliver if @driver.rejected?
        DriverMailer.driver_disabled_email(@user).deliver if @driver.disabled?
        DriverMailer.driver_approved_email(@user).deliver if @driver.active?
      end
    end
  end
end
