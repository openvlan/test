class V1::Backoffice::TripSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id, :amount, :status, :comments,
             :shipper_id, :start_datetime,
             :steps, :total_weight_in_lb, :needs_cooling, :trip_number, :distance,
             :status_change_audits, :start_date_string, :start_time_string

  def needs_cooling
    object&.orders.each do |order| # rubocop:todo Lint/SafeNavigationChain
      return true if order.needs_cooling?
    end

    false
  end

  def status_change_audits
    ActiveModelSerializers::SerializableResource.new(
      object.trip_status_change_audits.order(created_at: :desc),
      each_serializer: V1::TripStatusChangeAuditSerializer
    ).as_json[:trip_status_change_audits]
  end

  def steps
    object.steps.map { |step| serialize_step(step) }
  end

  private

  def serialize_step(step) # rubocop:todo Metrics/AbcSize
    basic_step = {
      action: step['action'],
      marketplace_order_id: step['marketplace_order_id'],
      open_hours: step.dig('address', 'open_hours')
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
