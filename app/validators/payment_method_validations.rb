module PaymentMethodValidations
  extend ActiveSupport::Concern

  included do
    validates_inclusion_of :payment_method, in: PaymentMethod::ALL
    validates :payment_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

    validates_presence_of :payment_email, if: :should_have_payment_email
    validates_absence_of :payment_email, unless: :should_have_payment_email

    private

    def should_have_payment_email
      [PaymentMethod::PAYPAL, PaymentMethod::VENMO].include?(payment_method)
    end
  end
end
