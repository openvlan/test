class V1::TripSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id, :amount, :status, :comments, :trip_number,
             :shipper_id, :start_datetime, :steps, :orders,
             :steps, :total_weight_in_lb, :needs_cooling, :distance

  def needs_cooling
    object&.orders.each do |order| # rubocop:todo Lint/SafeNavigationChain
      return true if order.needs_cooling?
    end

    false
  end

  def steps
    object.steps.map { |step| serialize_step(step) }
  end

  private

  def serialize_step(step)
    order = Order.find_by(marketplace_order_id: step['marketplace_order_id'])
    {
      action: step['action'],
      # rubocop:todo Layout/LineLength
      address: UserApiAddress.find_by(id: step['action'] == 'pickup' ? order.warehouse_address_id : order.delivery_location_id),
      # rubocop:enable Layout/LineLength
      marketplace_order_id: step['marketplace_order_id']
    }
  end

  def get_company_name(step, marketplace_order)
    return marketplace_order.seller_company_id if step['action'] == 'pickup'
  end
end
