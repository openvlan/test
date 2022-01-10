module V1
  module Drivers
    class ShippersController < ApplicationController
      before_action :set_driver
      skip_around_action :transactions_filter

      def set_current_location
        @driver.current_location(location_params)

        render status: :ok
      end

      def has_on_going_trips # rubocop:disable Naming/PredicateName
        render json: @driver.on_going_trips.any?
      end

      private

      def set_driver
        return if (@driver = Shipper.find_by(user_id: current_user.id))

        render json: { errors: I18n.t('errors.not_found.driver', id: current_user.id) },
               status: :not_found
      end

      def location_params
        params.permit(
          :latitude,
          :longitude,
          :timestamp
        )
      end
    end
  end
end
