# list shippers

module Services
  class ShippersController < BaseController
    def create
      shipper = Shipper.create(shipper_params.merge(provided_services: [Shipper::ProvidedServices::LTL]))
      return render json: { errors: shipper.errors.full_messages }, status: :unprocessable_entity unless shipper.valid?

      render json: shipper, status: :created # 201
    end

    def statuses_by_user_ids
      render json: Shipper
        .where(user_id: params[:user_ids])
        .pluck(:user_id, :status)
        .to_h
        .transform_values!(&:humanize)
    end

    private

    def shipper_params
      params.permit(:user_id, :first_name, :last_name)
    end
  end
end
