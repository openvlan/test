class PaymentMethod < ApplicationRecord
  PAYPAL = 'paypal'.freeze
  VENMO = 'venmo'.freeze
  ACH = 'ach'.freeze
  ALL = [PAYPAL, VENMO, ACH].freeze

  include PaymentMethodValidations

  belongs_to :shipper
end
