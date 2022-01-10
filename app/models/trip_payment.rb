class TripPayment < ApplicationRecord
  include PaymentMethodValidations

  belongs_to :trip

  validates_presence_of :paid_at, if: :confirmation_code?
  validates_absence_of :paid_at, unless: :confirmation_code?

  after_create :notify_to_trip
  scope :by_network_id, ->(network_id) { joins(:trip).merge(Trip.by_network_id(network_id)) }

  private

  def notify_to_trip
    trip.payment_created(self)
  end
end
