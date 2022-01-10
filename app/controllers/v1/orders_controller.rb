module V1
  class OrdersController < ApplicationController
    before_action :authorize_request, except: %i[destroy_by_marketplace_order]
    before_action :set_default_network_id, only: [:trip_planner]

    # rubocop:disable  Metrics/AbcSize
    def trip_planner
      # esta linea es temporal hasta implementar el feature de filtrado de network desde el BO - eze
      params[:network_id] = current_user.operable_network_ids.first if params[:network_id].nil?
      query = OrdersQuery.new
      orders_table = query.trip_planner(params).to_a.sort_by(&:created_at)
      marketplace_orders = marketplace_orders_by_id(orders_table.pluck(:marketplace_order_id))
      delivery_locations = delivery_locations_by_id(orders_table.pluck(:delivery_location_id).uniq)
      warehouses = delivery_locations_by_id(orders_table.pluck(:warehouse_address_id).uniq)
      orders_table = query.trip_planner(params).map { |order| OrderWithUserApiDecorator.new(order, warehouses) }

      result = ActiveModelSerializers::SerializableResource.new(orders_table,
                                                                each_serializer: V1::TripPlannerSerializer,
                                                                marketplace_orders: marketplace_orders,
                                                                delivery_locations: delivery_locations,
                                                                root: 'items').as_json
      render json: result
    end
    # rubocop:enable  Metrics/AbcSize

    def destroy_by_marketplace_order
      order_by_marketplace.destroy
      render status: :ok
    end

    private

    def delivery_locations_by_id(delivery_location_ids)
      UserApiAddress.find_all(delivery_location_ids)&.map do |location|
        [location['id'], location]
      end.to_h
    end

    def marketplace_orders_by_id(marketplace_order_ids)
      return {} unless marketplace_order_ids.any?

      MarketplaceOrder.palletized_quantity(marketplace_order_ids)
    end

    def order_by_marketplace
      @order_by_marketplace ||= Order.find_by(marketplace_order_id: params[:id])
    end
  end
end
