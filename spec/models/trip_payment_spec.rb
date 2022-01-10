require 'rails_helper'

RSpec.describe TripPayment, type: :model do
  it 'must have payment_email when payment_method is paypal or venmo' do
    [PaymentMethod::PAYPAL, PaymentMethod::VENMO].each do |payment_method|
      expect do
        build(:trip_payment, payment_method: payment_method).validate!
      end.to(
        raise_error(ActiveRecord::RecordInvalid, "Validation failed: Payment email can't be blank")
      )
    end
  end

  it 'must not have payment_email when payment_method is ach' do
    expect do
      build(:trip_payment, payment_method: PaymentMethod::ACH, payment_email: 'asd@asd.com').validate!
    end.to(
      raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Payment email must be blank')
    )
  end

  it 'does not accept any other payment methods' do
    expect do
      build(:trip_payment, payment_method: 'something_else').validate!
    end.to(
      raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Payment method is not included in the list')
    )
  end

  it 'validates email' do
    expect do
      build(:trip_payment, payment_method: PaymentMethod::VENMO, payment_email: 'something').validate!
    end.to(
      raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Payment email is invalid')
    )
  end

  it 'creates a valid ach trip payment' do
    expect do
      build(:trip_payment, payment_method: PaymentMethod::ACH, payment_email: nil).validate!
    end.not_to(raise_error)
  end
end
