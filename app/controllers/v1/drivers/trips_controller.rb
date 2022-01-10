module V1
  module Drivers
    class TripsController < ApplicationController
      before_action :set_driver, only: %i[trip_history index take start milestone complete cancel set_current_location has_on_going_trips]
      before_action :set_trip, only: %i[show take start milestone complete cancel]
      skip_around_action :transactions_filter, only: %i[take start milestone complete]

      def show
        render json: @trip, serializer: V1::DriversApp::TripSerializer
      end

      def index
        driver_trips = @driver.trips
        pending_trips = driver_trips.select { |trip| trip.pending_driver_confirmation? } + Trip.by_network_id(@driver.network_id).select(&:broadcasting?)
        accepted_trips = @driver.accepted_trips

        render json: {
          pending: serialized_resource(pending_trips),
          accepted: serialized_resource(accepted_trips)
        }, status: :ok # 200
      end 

      def trip_history
        render json: @driver.trips.includes(:trip_payment).order(start_datetime: :desc), each_serializer: V1::DriversApp::TripHistorySerializer, status: :ok
      end

      def take
        service = Trips::Take.call(@trip, @driver, current_user)
        return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

        render status: :ok # 200
      end

      def start
        service = Trips::Start.call(@trip, current_user)
        return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

        render status: :ok # 200
      end

      def milestone
        service = Trips::Milestone.call(@trip, milestone_params)
        return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

        render status: :ok # 200
      end

      def complete
        service = Trips::Complete.call(@trip, current_user)
        return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

        render status: :ok # 200
      end

      def cancel
        reason = params[:reason]
        service = Trips::CancelByDriver.call(@trip, @driver, reason)
        return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

        render status: :ok # 200
      end

      private

      def set_driver
        return render json: { errors: I18n.t('errors.not_found.driver', id: current_user.id) }, status: :not_found unless (@driver = Shipper.find_by(user_id: current_user.id))
      end

      def set_trip
        return render json: { errors: I18n.t('errors.not_found.trip', id: params[:id]) },
                        status: :not_found unless (@trip ||= Trip.find_by(id: params[:id]))
      end

      def create_trip_params
        params.permit(
          :amount,
          :start_date_string,
          :start_time_string,
          :shipper_id,
          :comments,
          steps: %i[action marketplace_order_id]
        )
      end

      def milestone_params
        params.permit(
          :name,
          :gps_coordinates,
          :comments,
          :marketplace_order_id,
          :step_index,
          data: {},
          files: [],
        )
      end

      def trip
        @trip ||= Trip.find_by(id: params[:id])
      end

      def serialized_resource(collection, adapter = :attributes)
        ActiveModelSerializers::SerializableResource.new(collection,
                                                         each_serializer: V1::DriversApp::TripListSerializer,
                                                         adapter: adapter).as_json
      end
    end
  end
end
