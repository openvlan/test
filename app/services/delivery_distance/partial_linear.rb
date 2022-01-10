module DeliveryDistance
  class PartialLinear
    prepend Service::Base

    DEFAULT_DELIVERY_COST = Rails.application.secrets.default_delivery_cost

    def initialize(origin, destiny)
      @origin = origin
      @destiny = destiny
    end

    def call
      calculate_distance
    end

    private

    def calculate_distance # rubocop:todo Metrics/AbcSize
      return DEFAULT_DELIVERY_COST if @origin&.gps_coordinates.nil?

      Math.acos(Math.cos(convert_to_radians(90 - @origin.gps_coordinates.coordinates.last)) *
      Math.cos(convert_to_radians(90 - @destiny.gps_coordinates.coordinates.last)) +
      Math.sin(convert_to_radians(90 - @origin.gps_coordinates.coordinates.last)) *
      Math.sin(convert_to_radians(90 - @destiny.gps_coordinates.coordinates.last)) *
      Math.cos(convert_to_radians(@origin.gps_coordinates.coordinates.first -
        @destiny.gps_coordinates.coordinates.first))) * 3958.75
    end

    def convert_to_radians(angle)
      angle / 180.0 * Math::PI
    end
  end
end
