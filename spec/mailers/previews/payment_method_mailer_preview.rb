# Preview all emails at http://localhost:3030/rails/mailers/payment_method_mailer
class PaymentMethodMailerPreview < ActionMailer::Preview
  def driver_venmo_payment_method_has_been_updated
    mailer(
      payment_method: PaymentMethod::VENMO,
      payment_email: 'venmo_payment@email.com'
    ).driver_payment_method_has_been_updated
  end

  def driver_ach_payment_method_has_been_updated
    mailer(
      payment_method: PaymentMethod::ACH
    ).driver_payment_method_has_been_updated
  end

  private

  def mailer(payment_method_attributes)
    PaymentMethodMailer.with(
      driver: Shipper.first,
      payment_method: PaymentMethod.new(payment_method_attributes)
    )
  end
end
