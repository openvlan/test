require 'api_utils'

module V1
  class DeliveryCostsController < ApiUtils::BaseController
    def calculate
      cost = DeliveryCosts::Free.new(delivery_cost_params[:order_price],
                                     delivery_cost_params[:order_weight],
                                     delivery_cost_params[:warehouse_id],
                                     delivery_cost_params[:buyer_company_id]).call
      return render json: { errors: cost.errors }, status: :unprocessable_entity unless cost.success?

      render json: cost.result
    end

    private

    def delivery_cost_params
      params.permit(:order_price, :order_weight, :warehouse_id, :buyer_company_id)
    end
  end
end
