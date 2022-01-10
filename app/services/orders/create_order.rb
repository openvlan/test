module Orders
  class CreateOrder
    prepend Service::Base

    def initialize(order_params)
      @order_params = order_params
    end

    def call
      create_order
    end

    private

    def create_order
      order_transaction

      return errors.add_multiple_errors(@order.errors.messages) unless @order.valid?

      @order
    end

    def order_transaction
      Order.transaction do
        order = Order.new(@order_params)
        order.save

        @order = order
      end
    end
  end
end
