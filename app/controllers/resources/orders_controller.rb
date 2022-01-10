module Resources
  class OrdersController < BaseController
    def show
      return render status: :not_found if order.nil?

      render json: order, serializer: Resources::OrderSerializer
    end

    def create
      order = Orders::CreateOrder.new(order_params).call

      return render json: { errors: order.errors }, status: :unprocessable_entity unless order.success?

      render json: order.result, status: :created
    end

    private

    def order_params
      params.permit(
        :id, :delivery_cost, :delivery_distance, :total_weight_in_lb, :warehouse_address_id,
        :delivery_location_id, :marketplace_order_id, :needs_cooling, :network_id
      )
    end

    def order
      @order ||= Order.find_by(id: params[:id])
    end
  end
end
