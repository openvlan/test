class V1::OrderSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id,
             :marketplace_order_id,
             :delivery_location_id,
             :warehouse_address_id,
             :marketplace_order,
             :delivery_location,
             :warehouse,
             :delivery_cost,
             :delivery_distance,
             :total_weight_in_lb,
             :created_at,
             :updated_at

  def warehouse
    UserApiAddress.find(object&.warehouse_address_id)
  end

  def delivery_location
    UserApiAddress.find(object&.delivery_location_id)
  end

  def marketplace_order
    MarketplaceOrder.find(object&.marketplace_order_id)
  end
end
