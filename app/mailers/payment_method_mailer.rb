class PaymentMethodMailer < ApplicationMailer
  def driver_payment_method_has_been_updated
    @payment_method = params[:payment_method]
    send_mail(
      to: params[:driver].user.email,
      subject: I18n.t(
        'payment_method_mailer.driver_payment_method_has_been_updated.subject'
      )
    )
  end
end
