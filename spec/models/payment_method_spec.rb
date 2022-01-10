require 'rails_helper'

RSpec.describe PaymentMethod, type: :model do
  before(:each) do
    allow_any_instance_of(Shipper).to receive(:set_user_role_network_id) { nil }
  end

  it 'must have payment_email when payment_method is paypal or venmo' do
    [PaymentMethod::PAYPAL, PaymentMethod::VENMO].each do |payment_method|
      expect do
        build(:payment_method, payment_method: payment_method).validate!
      end.to(
        raise_error(ActiveRecord::RecordInvalid, "Validation failed: Payment email can't be blank")
      )
    end
  end

  it 'must not have payment_email when payment_method is ach' do
    expect do
      create(:payment_method, payment_method: PaymentMethod::ACH, payment_email: 'asd@asd.com').validate!
    end.to(
      raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Payment email must be blank')
    )
  end

  it 'does not accept any other payment methods' do
    expect do
      create(:payment_method, payment_method: 'something_else').validate!
    end.to(
      raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Payment method is not included in the list')
    )
  end

  it 'validates email' do
    expect do
      create(:payment_method, payment_method: PaymentMethod::VENMO, payment_email: 'something').validate!
    end.to(
      raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Payment email is invalid')
    )
  end

  it 'creates a valid ach trip payment' do
    expect do
      create(:payment_method, payment_method: PaymentMethod::ACH, payment_email: nil).validate!
    end.not_to(raise_error)
  end
end
