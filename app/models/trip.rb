class Trip < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include AASM

  attribute :steps, :jsonb, default: []
  attribute :gateway_data, :jsonb, default: {}

  has_many :milestones, dependent: :destroy
  has_many :trip_orders
  has_many :trip_step_photos, dependent: :destroy
  has_many :orders, through: :trip_orders
  has_many :audits, as: :audited
  has_many :trip_status_change_audits
  has_one :trip_payment

  belongs_to :shipper, optional: true

  validates :start_datetime, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :steps, :network_id, presence: true
  validate :orders_network_consistency
  validate :shipper_belongs_to_same_network

  validates_with StepsValidator
  validates_with StartDatetimeValidator

  before_save :save_address
  before_save :set_network_id
  before_create :calculate_distance
  before_update :calculate_distance, if: :steps_changed?
  before_update :log_changes_if_correspond

  after_create :log_init_state

  attr_accessor :creator_user, :manual, :old_trip_number

  scope :delivery_at, ->(date) { where("((steps->0)->'schedule'->>'start')::date = ?", date.to_date) }
  scope :with_list_joins, -> { includes(%i[orders trip_orders shipper milestones]) }
  scope :by_network_id, ->(network_id) { where(network_id: network_id) }

  enum status: {
    broadcasting: '0',
    pending_driver_confirmation: '1',
    confirmed: '2',
    on_going: '3',
    completed: '4',
    canceled: '5'
  }

  aasm column: :status, enum: true do # rubocop:todo Metrics/BlockLength
    state :broadcasting, :pending_driver_confirmation, :confirmed, :on_going, :completed, :canceled

    event :assign_driver do
      transitions from: :broadcasting, to: :pending_driver_confirmation
    end

    event :confirm do
      transitions from: :pending_driver_confirmation, to: :confirmed,
                  after: :log_driver_confirm_from_pending_driver_confirmation
      transitions from: :broadcasting, to: :confirmed, after: :log_driver_confirm_from_broadcasting
    end

    event :start do
      transitions from: :confirmed, to: :on_going, after: :log_trip_started
    end

    event :finish do
      transitions from: :on_going, to: :completed, after: :log_trip_delivered
    end

    event :cancel do
      transitions from: :broadcasting, to: :canceled, after: :log_cancel
      transitions from: :pending_driver_confirmation, to: :canceled, after: :log_cancel_from_pending
      transitions from: :on_going, to: :canceled, after: :unassign_orders_and_log
      transitions from: :confirmed, to: :canceled, after: :unassign_orders_and_log
    end

    event :cancel_driver do
      transitions from: :pending_driver_confirmation, to: :canceled, after: :log_cancel_from_pending
      transitions from: :confirmed, to: :canceled,
                  after: :reschedule
    end
  end

  def self.first
    order(created_at: :asc).first
  end

  def self.last
    order(created_at: :desc).first
  end

  def self.build_manually(args = {})
    status = args[:shipper_id].nil? ? :broadcasting : :pending_driver_confirmation
    Trip.new(args.merge(status: status, manual: true))
  end

  def trip_type
    if orders.any? { |o| o.warehouse.location_type.downcase == 'port'.freeze }
      TripType::DRAYAGE
    else
      orders.any?(&:needs_cooling) ? TripType::LTL_REFRIGERATED : TripType::LTL
    end
  end

  def total_weight_in_lb
    order_ids = steps.map { |s| s['marketplace_order_id'] }.uniq
    orders = Order.where(marketplace_order_id: order_ids)
    orders.sum(:total_weight_in_lb)
  end

  def drayage?
    trip_type == TripType::DRAYAGE
  end

  def ltl_refrigerated?
    trip_type == TripType::LTL_REFRIGERATED
  end

  def ltl?
    trip_type == TripType::LTL
  end

  def pickup_window
    HashWithIndifferentAccess.new(initial_pickup['schedule'])
  end

  def dropoff_window
    HashWithIndifferentAccess.new(last_dropoff['schedule'])
  end

  def net_income
    amount.to_f - deliveries_amount
  end

  def confirm_driver(driver, triggered_user)
    self.shipper = driver
    confirm(triggered_user)
  end

  def cancel_by_driver(driver, reason = nil)
    raise DriverIsNotCurrentlyAssignedException, driver if shipper != driver

    self.cancelation_reason = reason
    cancel_driver(driver.user)
  end

  def log_photo_uploaded(user, photo)
    url = photo.url
    trip_status_change_audits.create(
      status: aasm.current_state,
      event: 'Photo uploaded',
      comments: "#{user.email} uploaded a photo. <a href='#{url}'>View Photo</a>"
    )
  end

  # rubocop:disable  Metrics/AbcSize
  def milestone_created(milestone)
    action = milestone.name == 'deliver' ? 'Delivered' : 'Picked up'
    step = milestone.trip.steps.detect do |s|
      s['action'] == milestone.name && s['marketplace_order_id'].to_i == milestone.marketplace_order_id.to_i
    end
    at = step['address']['formatted_address']
    n_photos = "#{milestone.photos&.count} photos uploaded." if milestone.photos&.any?

    comment = "Driver #{shipper.full_name} informed that" \
              "he #{action.downcase} MO ##{milestone.marketplace_order_id} at #{at}. #{n_photos}"

    trip_status_change_audits.create(
      status: aasm.current_state,
      event: "#{action} products",
      comments: comment
    )
  end
  # rubocop:enable  Metrics/AbcSize

  def log_payment_request(payment)
    trip_status_change_audits.create(
      status: aasm.current_state,
      event: 'Trip payment request',
      comments: "Driver #{shipper.full_name} requested payment thru #{payment.payment_method}"
    )
  end

  def log_payment_paid(user)
    trip_status_change_audits.create(
      status: aasm.current_state,
      event: 'Trip paid',
      comments: "#{user.full_name} marked this trip as Paid"
    )
  end

  def payment_created(payment)
    log_payment_request(payment)
  end

  def network_id
    set_network_id if self[:network_id].nil?
    self[:network_id]
  end

  # start_date_string example: 2011-02-11
  # start_time_string example: 17:00
  def set_start_datetime(start_date_string, start_time_string)
    year, month, day = (start_date_string || self.start_date_string).split('-')
    hour, minutes = (start_time_string || self.start_time_string).split(':')
    time_with_offset = timezone.time_with_offset(Time.utc(year, month, day, hour, minutes))
    self.start_datetime = time_with_offset - time_with_offset.utc_offset
  end

  def start_date_string
    start_datetime_in_timezone.strftime('%Y-%m-%d')
  end

  def start_time_string
    start_datetime_in_timezone.strftime('%H:%M')
  end

  def start_datetime_in_timezone
    timezone.time_with_offset(start_datetime.utc) if start_datetime
  end

  def timezone
    Timezone[timezone_name]
  end

  def update_timezone_name
    first_order = Order.find_by(marketplace_order_id: steps.first['marketplace_order_id'])
    self.timezone_name = UserApiAddress.find(first_order.warehouse_address_id).timezone_name
  end

  private

  def reschedule(user)
    close_procedure
    log_cancel(user)
  end

  def close_procedure
    enough_time? ? TripReschedule.new(self).run : unassign_driver_orders
  end

  def unassign_orders_and_log(user)
    unassign_driver_orders
    log_cancel(user)
  end

  def unassign_driver_orders
    MarketplaceOrder.bulk_driver_unassign(
      orders.pluck(:marketplace_order_id)
    )
    notify_cancellation_with_no_enough_time
  end

  def enough_time?
    # TODO: revisar
    TripEnoughTime.enough? start_datetime
  end

  def notify_cancellation_with_no_enough_time
    TripMailer.notify_logistics_trip_cancelled_near_starting_time(self).deliver
    orders.each do |order|
      TripMailer.buyer_notice_shipper_cancelled_near_delivery_time(order.marketplace_order_id).deliver
      TripMailer.seller_notice_shipper_cancelled_near_delivery_time(order.marketplace_order_id).deliver
    end
  end

  def initial_pickup
    @initial_pickup ||= steps.detect { |step| step['action'] == 'pickup' }
  end

  def last_dropoff
    @last_dropoff ||= steps.reverse.detect { |step| step['action'] == 'dropoff' }
  end

  def deliveries_amount
    deliveries.sum(&:total_amount).to_f
  end

  def calculate_distance
    total_distance = DeliveryDistance::Total.new(steps).call

    self.distance = total_distance.result
  end

  def save_address
    steps.each_with_index do |step, index|
      order = Order.find_by(marketplace_order_id: step['marketplace_order_id'])

      steps[index]['address'] =
        UserApiAddress.find_by(id: step['action'] == 'pickup' ? order.warehouse_address_id : order.delivery_location_id)
    end

    self.steps = steps
  end

  def log_init_state
    if manual
      if broadcasting?
        log_manual_broadcasting_creation
      else
        log_manual_pending_confirmation_creation
      end
    else
      log_automatic_creation
    end
  end

  def log_automatic_creation
    trip_status_change_audits.create(
      status: aasm.current_state,
      event: 'Trip created',
      comments: "Created automatically because trip ##{old_trip_number} was canceled"
    )
  end

  def log_manual_pending_confirmation_creation
    trip_status_change_audits.create(
      status: aasm.current_state,
      event: 'Trip awaiting driver confirmation',
      comments: "#{creator_user.email} created this trip and manually assigned it to driver #{shipper.full_name}"
    )
  end

  def log_manual_broadcasting_creation
    trip_status_change_audits.create(
      status: aasm.current_state,
      event: 'Trip created',
      comments: "Created by #{creator_user.email}"
    )
  end

  def log_driver_confirm_from_broadcasting
    trip_status_change_audits.create(
      status: aasm.to_state,
      event: 'Driver confirmed',
      comments: "Driver #{shipper.full_name} will be doing this trip"
    )
  end

  def log_driver_confirm_from_pending_driver_confirmation(user)
    if user.id == shipper&.user_id
      trip_status_change_audits.create(
        status: aasm.to_state,
        event: 'Trip confirmed',
        comments: "Driver #{shipper.full_name} accepted the trip using the app"
      )
    else
      trip_status_change_audits.create(
        status: aasm.to_state,
        event: 'Trip confirmed',
        comments: "#{user.email} marked this trip as Confirmed"
      )
    end
  end

  def log_trip_started(user)
    if shipper&.user_id == user.id
      trip_status_change_audits.create(
        status: aasm.to_state,
        event: 'Trip started',
        comments: "Driver #{shipper.full_name} started the trip using the app"
      )
    else
      trip_status_change_audits.create(
        status: aasm.to_state,
        event: 'Trip started',
        comments: "#{user.email} marked this trip as started"
      )
    end
  end

  def log_trip_delivered(user)
    if shipper&.user_id == user.id
      trip_status_change_audits.create(
        status: aasm.to_state,
        event: 'Trip completed',
        comments: "Driver #{shipper.full_name} indicated that he did the last delivery of this trip using the app"
      )
    else
      trip_status_change_audits.create(
        status: aasm.to_state,
        event: 'Trip completed',
        comments: "#{user.email} marked this trip as Complete"
      )
    end
  end

  def log_cancel_from_pending(user)
    if shipper&.user_id == user.id
      trip_status_change_audits.create!(
        status: aasm.to_state,
        event: 'Trip refused by driver',
        comments: "Driver #{shipper.full_name} refused the trip using the app"
      )

      notify_driver_trip_refused
    else
      trip_status_change_audits.create!(
        status: aasm.to_state,
        event: 'Trip canceled',
        comments: "#{user.email} marked this trip as Canceled"
      )
    end
  end

  def notify_driver_trip_refused
    TripMailer.driver_trip_refused_email(self).deliver
  end

  def log_cancel(user)
    if shipper&.user_id == user.id
      trip_status_change_audits.create!(
        status: aasm.to_state,
        event: 'Trip canceled',
        comments: "Driver #{shipper.full_name} canceled the trip using the app"
      )
    else
      trip_status_change_audits.create!(
        status: aasm.to_state,
        event: 'Trip canceled',
        comments: "#{user.email} marked this trip as Canceled"
      )
    end
  end

  def log_changes_if_correspond
    changes = changes_as_text
    return if changes.blank?

    unless %i[pending_driver_confirmation broadcasting].include? aasm.current_state.to_sym
      raise "Cannot modify trip because is on status: #{aasm.current_state}." \
            'Only accepts changes on broadcasting or pending_driver_confirmation status'
    end

    trip_status_change_audits.create(
      status: aasm.current_state,
      event: 'Trip edited',
      comments: changes
    )
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def changes_as_text
    changes = ''
    changes += "Comment changed from: '#{comments_was}' to: '#{comments}' <br>" if comments_changed?
    changes += "Amount changed from: $ #{amount_was} to: $ #{amount} <br>" if amount_changed?
    changes += "Start Time changed from: #{start_datetime_was} to: #{start_datetime} <br>" if start_datetime_changed?
    if steps_changed? && steps_was != steps
      steps_before = steps_was.pluck('action', 'marketplace_order_id').map { |s| "#{s.first} order: #{s.second}" }
      steps_now = steps.pluck('action', 'marketplace_order_id').map { |s| "#{s.first} order: #{s.second}" }
      changes += "Steps changed from: #{steps_before} to: #{steps_now} <br>" if steps_before != steps_now
    end
    changes
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def orders_network_consistency
    errors.add(:network_id, 'is multiple regarding to its orders') if orders_have_different_network_id
  end

  def orders_have_different_network_id
    network_ids = orders.collect(&:network_id).uniq
    network_ids.empty? || network_ids.count > 1 || network_ids.first.nil?
  end

  def shipper_belongs_to_same_network
    errors.add(:network_id, 'is different from shipper network') if shipper_has_different_network_id
  end

  def shipper_has_different_network_id
    shipper.present? && shipper.network_id != network_id
  end

  def set_network_id
    self.network_id = orders_network_id
  end

  def orders_network_id
    orders.first.network_id
  end

  class DriverIsNotCurrentlyAssignedException < RuntimeError
    @sym = :DRIVER_IS_NOT_CURRENT_ASSIGNED

    class << self
      attr_reader :sym
    end

    def initialize(driver)
      super("Driver named #{driver.full_name} is not assigned to this trip")
    end
  end
end
