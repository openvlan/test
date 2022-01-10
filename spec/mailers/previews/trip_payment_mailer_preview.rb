# Preview all emails at http://localhost:3030/rails/mailers/trip_payment_mailer
class TripPaymentMailerPreview < ActionMailer::Preview
  def driver_payment_pending
    mailer.driver_payment_pending
  end

  def tiko_employee_payment_pending
    mailer.tiko_employee_payment_pending
  end

  private

  def mailer
    TripPaymentMailer.with(trip_payment: TripPayment.last)
  end
end
