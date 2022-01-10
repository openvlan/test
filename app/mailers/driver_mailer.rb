class DriverMailer < ApplicationMailer
  TIKO_BUYERS_URL = Rails.application.secrets.tiko_buyers_app
  TIKO_SELLERS_URL = Rails.application.secrets.tiko_sellers_app
  BACKOFFICE_URL = Rails.application.secrets.tiko_backoffice_app
  LOGISTIC_ADMIN_EMAIL = Rails.application.secrets.tiko_logistics_email

  def driver_approved_email(user)
    @redirect_url = DynamicLinksService.new.create_link('/')
    subject = I18n.t('driver_mailer.driver_approved_email.subject')

    send_mail(to: user.email, subject: subject)
  end

  def driver_rejected_email(user)
    subject = I18n.t('driver_mailer.driver_rejected_email.subject')

    send_mail(to: user.email, subject: subject)
  end

  def driver_pending_email(user)
    subject = I18n.t('driver_mailer.driver_pending_email.subject')

    send_mail(to: user.email, subject: subject)
  end

  def driver_disabled_email(user)
    subject = I18n.t('driver_mailer.driver_disabled_email.subject')

    send_mail(to: user.email, subject: subject)
  end

  def driver_awaiting_vetting_email(shipper)
    @driver_name = shipper.full_name
    @application_date = shipper.created_at.in_time_zone.strftime('%m/%d/%y %l:%M %p')
    @application_number = Shipper.count
    @redirect_url = "#{BACKOFFICE_URL}/drivers/#{shipper.id}"
    subject = I18n.t('driver_mailer.driver_awaiting_vetting_email.subject', application_number: @application_number)

    send_mail(to: LOGISTIC_ADMIN_EMAIL, subject: subject)
  end
end
