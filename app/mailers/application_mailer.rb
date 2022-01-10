require 'api_utils'

class ApplicationMailer < ApiUtils::BaseMailer
  LOGISTIC_ADMIN_EMAIL = Rails.application.secrets.tiko_logistics_email
  LOGISTIC_ADMIN_EMAIL_NAME = Rails.application.secrets.tiko_logistics_email_name
  LOGISTIC_ADMIN_FULL_EMAIL = "#{LOGISTIC_ADMIN_EMAIL_NAME} <#{LOGISTIC_ADMIN_EMAIL}>".freeze

  TIKO_NOTIFICATION_EMAIL_NAME = Rails.application.secrets.tiko_notification_email_name
  TIKO_NOTIFICATION_EMAIL = Rails.application.secrets.tiko_notification_email
  TIKO_NOTIFICATION_FULL_EMAIL = "#{TIKO_NOTIFICATION_EMAIL_NAME} <#{TIKO_NOTIFICATION_EMAIL}>".freeze

  default from: LOGISTIC_ADMIN_FULL_EMAIL

  private

  def send_mail(to:, subject:, with_bbc: true)
    bcc = []
    bcc = [Rails.application.secrets.tiko_bbc_from_email] if with_bbc
    super(to: to, subject: subject, bcc: bcc)
  end
end
