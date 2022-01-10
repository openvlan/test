class Order < ApplicationRecord
  include TripType

  has_many :trip_orders
  has_many :trips, through: :trip_orders

  validates :marketplace_order_id, :warehouse_address_id, :delivery_location_id, :network_id,
            :delivery_cost, :delivery_distance, :total_weight_in_lb, presence: true

  validates_uniqueness_of :marketplace_order_id
  validate :warehouse_address_exists, on: :create

  def warehouse_address_exists
    UserApiAddress.find(warehouse_address_id) unless Rails.env.test?
  end

  def network
    Network.find network_id
  end

  def type
    'Order'.freeze
  end

  def is_type?(suspected_type) # rubocop:todo Naming/PredicateName
    type == suspected_type
  end

  def marketplace_order
    MarketplaceOrder.find marketplace_order_id
  end

  def total_amount
    (amount.to_f - bonified_amount.to_f).to_f
  end

  def assigned?
    return false if trips.nil? || trips.empty?

    !trips.all?(&:canceled?)
  end

  def shipper
    return nil if trips.empty?

    trips.order(created_at: :desc).first.shipper
  end

  def trip_type
    if warehouse.location_type.downcase == 'port'.freeze
      TripType::DRAYAGE
    else
      needs_cooling ? TripType::LTL_REFRIGERATED : TripType::LTL
    end
  end

  def warehouse
    UserApiWarehouseAddress.find(warehouse_address_id)
  end
end
