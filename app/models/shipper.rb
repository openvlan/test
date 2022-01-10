class Shipper < ApplicationRecord # rubocop:todo Metrics/ClassLength
  module ProvidedServices
    DRAYAGE = 'drayage'.freeze
    LTL = 'ltl'.freeze
    ALL = [DRAYAGE, LTL].freeze
  end

  include AASM
  audited
  has_associated_audits

  attribute :phone_num

  attribute :data, :jsonb, default: {}
  attribute :national_ids, :jsonb, default: {}

  # TO-DO: We should remove this logic from here
  attribute :devices, :jsonb, default: {}

  scope :with_android_device_tokens, -> { where("devices->>'android' IS NOT NULL") }
  scope :verified, -> { where(verified: true) }

  after_create :set_initial_status
  before_validation :set_network_id

  enum status: {
    pending_email_validation: '0',
    pending_mobile_validation: '1',
    onboarding_in_progress: '2',
    pending_vetting: '3',
    active: '4',
    rejected: '5',
    disabled: '6',
    deleted: '7'
  }

  aasm column: :status, enum: true do # rubocop:todo Metrics/BlockLength
    state :pending_email_validation, initial: true
    state :pending_email_validation, :pending_mobile_validation, :onboarding_in_progress,
          :pending_vetting, :active, :rejected, :disabled, :deleted

    event :validate_email do
      transitions from: :pending_email_validation, to: :pending_mobile_validation
    end

    event :validate_mobile_phone do
      transitions from: :pending_mobile_validation, to: :onboarding_in_progress
    end

    event :finish_onboarding do
      transitions from: :onboarding_in_progress, to: :pending_vetting
    end

    event :activate do
      transitions from: :pending_vetting, to: :active
      transitions from: :rejected, to: :active
      transitions from: :disabled, to: :active
    end

    event :disable do
      transitions from: :pending_vetting, to: :disabled
      transitions from: :active, to: :disabled
      transitions from: :rejected, to: :disabled
    end

    event :reject do
      transitions from: :pending_vetting, to: :rejected
      transitions from: :active, to: :rejected
      transitions from: :disabled, to: :rejected
    end
  end

  has_many :verifications, as: :verificable, dependent: :destroy
  has_many :milestones, through: :trips
  has_many :trips, dependent: :nullify
  has_one :vehicle, dependent: :destroy
  has_one :license, dependent: :destroy
  has_one :payment_method, dependent: :destroy
  belongs_to :company, optional: true
  accepts_nested_attributes_for :company, :vehicle, :license, allow_destroy: true

  validates :user_id, uniqueness: true, on: :create
  validates :user_id, presence: true, on: :create
  validates :provided_services, presence: true, array: {
    inclusion: { in: [ProvidedServices::DRAYAGE, ProvidedServices::LTL] }
  }

  before_save :update_phone_number_on_user, if: proc { |shipper| shipper.phone_num_changed? }

  scope :with_joins, lambda {
    left_outer_joins(:license).joins(:vehicle, company: :address).includes(:vehicle, company: :address)
  }

  scope :providing_drayage, -> { where('?  = ANY(shippers.provided_services)', ProvidedServices::DRAYAGE) }
  scope :providing_ltl, -> { where('?  = ANY(shippers.provided_services)', ProvidedServices::LTL) }

  scope :search, lambda { |text|
                   where("lower(shippers.last_name) LIKE :l OR
            lower(companies.name) LIKE :l OR
            lower(addresses.city) LIKE :l OR
            lower(addresses.state) LIKE :l", l: "%#{text.downcase}%")
                 }

  scope :search_by_status, lambda { |text|
                             # rubocop:todo Layout/LineLength
                             where('shippers.status LIKE ?', Shipper.statuses[text.downcase.parameterize.underscore].to_s)
                             # rubocop:enable Layout/LineLength
                           }

  scope :search_by_vehicle_type, ->(type) { where('vehicles.truck_type = ?', type.to_i) }
  scope :with_refrigeration, lambda {
                               joins(:vehicle)
                                 .where('vehicles.truck_type = ?', Vehicle::REFRIGERATED_INDEX)
                             }
  scope :by_network_id, ->(network_id) { where(network_id: network_id) }

  DEFAULT_REQUIREMENT_TEMPLATE = {
    'verified' => false,
    'uri' => nil,
    'data' => {},
    'expiration_date' => ''
  }.freeze

  REQUIREMENTS = %w[
    habilitation_transport_food
    sanitary_notepad
  ].freeze

  MINIMUM_REQUIREMENTS = %w[
    driving_license
    is_monotributista
    has_cuit_or_cuil
    has_banking_account
    has_paypal_account
  ].freeze

  def self.filter_active_by_trip(trip)
    shippers = Shipper.active.by_network_id(trip.network_id)
    shippers = shippers.providing_drayage if trip.drayage?
    shippers = shippers.providing_ltl if trip.ltl?
    shippers = shippers.providing_ltl.with_refrigeration if trip.ltl_refrigerated?
    shippers
  end

  def set_initial_status
    onboarding_in_progress!
  end

  # TO-DO: We should remove this logic from here
  def has_device?(device_hash = {}) # rubocop:todo Naming/PredicateName
    type, token = device_hash.fetch_values(:type, :token)

    return false unless devices.keys.include?(type)

    devices[type].key?(token)
  end

  def requirements
    REQUIREMENTS.each_with_object({}) do |requirement, _hash| # rubocop:todo Lint/UnderscorePrefixedVariableName
      _hash[requirement] = DEFAULT_REQUIREMENT_TEMPLATE
    end.deep_merge(attributes['requirements'].to_h)
  end

  def minimum_requirements
    MINIMUM_REQUIREMENTS.each_with_object({}) do |requirement, _hash| # rubocop:todo Lint/UnderscorePrefixedVariableName
      _hash[requirement] = DEFAULT_REQUIREMENT_TEMPLATE
    end.deep_merge(attributes['minimum_requirements'].to_h)
  end

  def accepted_trips
    trips.select { |trip| trip.confirmed? || trip.on_going? }
  end

  def on_going_trips
    trips.select(&:on_going?)
  end

  def code
    user.code
  end

  def phone_num
    @phone_num ||= user.phone
  end

  # rubocop:disable Style/GlobalVars
  def current_location(location_params)
    $redis.set(id, location_params.to_json)
  end

  def last_location
    redis_string = $redis.get(id)
    redis_string ? JSON.parse(redis_string) : nil
  end
  # rubocop:enable Style/GlobalVars

  def phone_num=(value)
    phone_num_will_change! unless value == @phone_num
    @phone_num = value
    user.phone = value
  end

  def payment_method_name
    payment_method&.name
  end

  def email
    user&.email
  end

  def user
    @user ||= User.find_by(id: user_id) unless user_id.blank?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def all_audits
    audits +
      associated_audits +
      company_audits +
      company_associated_audits
  end

  def company_audits
    return [] if company.nil?

    company.audits
  end

  def company_associated_audits
    return [] if company.nil?

    company.associated_audits
  end

  def provide_service_drayage?
    provide_service? ProvidedServices::DRAYAGE
  end

  def provide_service_ltl?
    provide_service? ProvidedServices::LTL
  end

  private

  def provide_service?(service)
    provided_services.include? service
  end

  def update_phone_number_on_user
    user.save
  end

  def set_network_id
    return if network_id == company&.network_id

    self.network_id = company&.network_id
    set_user_role_network_id
  end

  def set_user_role_network_id
    user.update_driver_network_id(network_id)
  end
end
