class MarketplaceOrder < MarketplaceResource
  self.element_name = :order

  module Status
    PAYMENT_PENDING = 'payment_pending'.freeze
    PICKUP_PENDING = 'pickup_pending'.freeze
    DELIVERY_SCHEDULED = 'delivery_scheduled'.freeze
    IN_DELIVERY = 'in_delivery'.freeze
    DELIVERED = 'delivered'.freeze
    CANCELED = 'canceled'.freeze
    REFUND_PENDING = 'refund_pending'.freeze
    REFUNDED = 'refunded'.freeze
  end

  def deliver
    post(:deliver)
  end

  def self.find_all(order_ids)
    result = post(:find_all, nil, { order_ids: order_ids }.to_json)
    JSON.parse(result.read_body)['orders']
  end

  def self.palletized_quantity(order_ids)
    result = post(:palletized_quantity, nil, { order_ids: order_ids }.to_json)
    JSON.parse(result.read_body)
  end

  DELIVERY_BY_TIKO = 'Delivery by TIKO'.freeze

  def delivery_by_tiko?
    delivery_method == DELIVERY_BY_TIKO
  end

  def self.bulk_deliver(order_ids)
    post(:bulk_deliver, order_ids: order_ids)
  end

  def self.bulk_driver_assign(order_ids)
    post(:bulk_driver_assign, order_ids: order_ids)
  end

  def self.bulk_driver_unassign(order_ids)
    post(:bulk_driver_unassign, order_ids: order_ids)
  end

  def driver_pickup
    post(:driver_pickup)
  end
end
