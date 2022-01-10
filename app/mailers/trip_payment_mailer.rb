class TripPaymentMailer < ApplicationMailer
  before_action :set_instance_variables

  def driver_payment_pending
    @trip_payment = params[:trip_payment]
    subject = I18n.t(
      'trip_payment_mailer.driver_payment_pending.subject',
      trip_number: @trip_payment.trip.trip_number
    )

    send_mail(to: @trip_payment.trip.shipper.user.email, subject: subject)
  end

  def tiko_employee_payment_pending
    @trip_payment = params[:trip_payment]
    subject = I18n.t(
      'trip_payment_mailer.tiko_employee_payment_pending.subject',
      trip_number: @trip_payment.trip.trip_number
    )

    send_mail(to: @tiko_employees_email, subject: subject)
  end

  private

  def set_instance_variables
    @tiko_employees_email = Rails.application.secrets.tiko_employees_email
    @backoffice_url = Rails.application.secrets.tiko_backoffice_app
    @payment_list_route = '/orders/payments'
  end
end
