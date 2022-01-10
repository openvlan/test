module DeliveryDistance
  class Total
    prepend Service::Base

    def initialize(steps)
      @steps = steps
      @distance = 0
    end

    def call
      calculate_distance

      @distance
    end

    private

    def calculate_distance # rubocop:todo Metrics/AbcSize
      @steps.each_with_index do |step, index|
        return if @steps[index + 1].nil? # rubocop:todo Lint/NonLocalExitFromIterator

        origin_order = Order.find_by(marketplace_order_id: step['marketplace_order_id'])
        destiny_order = Order.find_by(marketplace_order_id: @steps[index + 1]['marketplace_order_id'])

        origin_location = location(origin_order, step['action'])
        destiny_location = location(destiny_order, @steps[index + 1]['action'])

        step_distance = DeliveryDistance::PartialLinear.new(origin_location, destiny_location).call

        @distance += step_distance.result
      end
    end

    def location(order, action)
      return UserApiAddress.find(order.warehouse_address_id) if action.eql? 'pickup'

      UserApiAddress.find(order.delivery_location_id)
    end
  end
end
