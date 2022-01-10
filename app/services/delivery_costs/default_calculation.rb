module DeliveryCosts
  class DefaultCalculation
    prepend Service::Base

    USER_API = Rails.application.secrets.user_endpoint
    HEADERS = {
      Authorization: "Token token=#{Rails.application.secrets.user_token}"
    }.freeze

    FIX_RATE = Rails.application.secrets.fix_rate
    RATE_PER_MILE = Rails.application.secrets.rate_per_mile
    RATE_PER_TONE = Rails.application.secrets.rate_per_tone
    INSURANCE_RATE = Rails.application.secrets.insurance_rate
    DEFAULT_DELIVERY_COST = Rails.application.secrets.default_delivery_cost

    def initialize(order_price, order_weight, warehouse_id, buyer_company_id)
      @order_price = order_price
      @order_weight = order_weight
      @warehouse = warehouse(warehouse_id)
      @delivery_locations = delivery_locations(buyer_company_id)
    end

    def call
      calculate_delivery_cost
    end

    private

    def calculate_delivery_cost
      return errors if errors.any?

      calculate_cost_by_locations

      return errors if errors.any?

      @delivery_locations
    end

    def calculate_cost_by_locations # rubocop:todo Metrics/AbcSize
      @delivery_locations.each_with_index do |delivery_location, index|
        if delivery_location.gps_coordinates.nil?
          @delivery_locations[index].delivery_cost = DEFAULT_DELIVERY_COST
          not_found_message = I18n.t('errors.invalid.delivery_gps', delivery_location_id: delivery_location.id)
          send_not_found_event(not_found_message) || next
        end
        distance = DeliveryDistance::PartialLinear.new(@warehouse, delivery_location).call

        @delivery_locations[index].delivery_cost = shipping_cost(distance.result).round(2)
        @delivery_locations[index].delivery_distance = distance.result.round(2)
      end
    end

    def shipping_cost(_distance)
      NotImplementedError.raise
    end

    def warehouse(warehouse_id)
      warehouse = UserApiAddress.find(warehouse_id)

      if warehouse.gps_coordinates.nil?
        send_not_found_event(I18n.t('errors.invalid.warehouse_gps', warehouse_id: warehouse_id))
      end

      warehouse
    rescue ActiveResource::ResourceNotFound
      send_not_found_event(I18n.t('errors.not_found.warehouse', warehouse_id: warehouse_id))
      nil
    end

    def delivery_locations(buyer_company_id)
      UserApiCompany.find(buyer_company_id).delivery_addresses
    rescue ActiveResource::ResourceNotFound
      errors.add(
        :invalid_buyer_company,
        I18n.t('errors.not_found.buyer_company', buyer_company_id: buyer_company_id)
      )
    end

    def send_not_found_event(message)
      Raven.send_event(code: 404, message: message)
    end
  end
end
