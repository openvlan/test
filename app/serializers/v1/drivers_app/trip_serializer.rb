class V1::DriversApp::TripSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id, :amount, :status, :comments, :orders,
             :shipper_id, :start_datetime,
             :steps, :total_weight_in_lb, :needs_cooling, :trip_number, :distance,
             :milestones, :step_index

  def step_index
    object.milestones.any? ? object.milestones.count : 0
  end

  def needs_cooling
    object&.orders.each do |order| # rubocop:todo Lint/SafeNavigationChain
      return true if order.needs_cooling?
    end

    false
  end

  def orders
    marketplace_orders = []
    object&.orders.each do |order| # rubocop:todo Lint/SafeNavigationChain
      marketplace_orders.push MarketplaceOrder.find(order.marketplace_order_id)
    end

    marketplace_orders
  end

  def steps
    object.steps.map { |step| serialize_step(step) }
  end

  private

  def serialize_step(step) # rubocop:todo Metrics/AbcSize
    basic_step = {
      action: step['action'],
      marketplace_order_id: step['marketplace_order_id']
    }

    order = Order.find_by(marketplace_order_id: step['marketplace_order_id'])

    return basic_step unless order

    # rubocop:todo Layout/LineLength
    address = UserApiAddress.find_by(id: step['action'] == 'pickup' ? order.warehouse_address_id : order.delivery_location_id)
    # rubocop:enable Layout/LineLength

    basic_step.merge({
                       address: address.formatted_address,
                       coordinates: address.latlng,
                       # rubocop:todo Layout/LineLength
                       company_name: UserApiCompany.find_by(id: step['action'] == 'pickup' ? address.seller_company_id : address.buyer_company_id)&.name
                       # rubocop:enable Layout/LineLength
                     })
  end
end
