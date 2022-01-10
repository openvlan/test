module V1
  class TripsController < ApplicationController
    skip_around_action :transactions_filter, only: %i[create cancel confirm_driver start complete]
    before_action :set_default_network_id, only: [:list]

    def create
      trip = Trips::Create.call(trip_params, current_user)
      return render json: { errors: trip.errors }, status: :unprocessable_entity unless trip.success?

      render json: trip.result, status: :created # 201
    end

    def show
      return render status: :not_found if trip.nil?

      render json: trip, serializer: V1::Backoffice::TripSerializer
    end

    def update
      return render status: :not_found if trip.nil?

      updated_trip = Trips::Update.new(trip, trip_params).call
      unless updated_trip.success?
        return render json: { errors: updated_trip.errors },
                      status: :unprocessable_entity
      end

      render json: updated_trip.result
    end

    def cancel
      return render json: { errors: I18n.t('errors.not_found.trip', id: params[:id]) }, status: :not_found unless trip

      service = Trips::Cancel.call(trip, current_user)
      return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

      render status: :ok
    end

    def confirm_driver
      service = Trips::Take.call(trip, Shipper.find(params[:shipper_id]), current_user)
      return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

      render status: :ok
    end

    def start
      service = Trips::Start.call(trip, current_user)
      return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

      render status: :ok
    end

    def complete
      service = Trips::Complete.call(trip, current_user)
      return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

      render status: :ok
    end

    def list
      result = ActiveModelSerializers::SerializableResource.new(
        trips_list(list_params),
        each_serializer: V1::Backoffice::TripListSerializer,
        root: 'items'
      ).as_json

      render json: result, status: :ok
    end

    private

    def trips_list(params)
      TripsQuery.new.list(
        network_id: params[:network_id],
        start_datetime: params[:start_datetime],
        end_datetime: params[:end_datetime],
        status: params[:status]
      ).to_a
    end

    def trip
      @trip ||= Trip.find_by(id: params[:id])
    end

    def list_params
      params.permit(
        :per_page,
        :start_datetime,
        :end_datetime,
        :network_id,
        status: []
      )
    end

    def trip_params
      params.permit(
        :amount,
        :start_date_string,
        :start_time_string,
        :shipper_id,
        :comments,
        steps: %i[action marketplace_order_id]
      )
    end
  end
end
