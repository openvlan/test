module Shippers
  module Emails
    class Onboarding
      TIKO_EMPLOYEES_EMAIL = Rails.application.secrets.tiko_employees_email
      LOGISTIC_ADMIN_EMAIL = Rails.application.secrets.tiko_logistics_email
      BACKOFFICE_URL = Rails.application.secrets.tiko_backoffice_app

      def initialize(driver)
        @driver = driver
      end

      def call
        send_vetting_email
        send_welcome_email
      end

      private

      def send_vetting_email
        DriverMailer.driver_awaiting_vetting_email(@driver).deliver
      end

      def send_welcome_email
        user = User.find(@driver.user_id)
        DriverMailer.driver_pending_email(user).deliver
      end
    end
  end
end
