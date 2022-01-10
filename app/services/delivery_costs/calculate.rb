module DeliveryCosts
  class Calculate < DefaultCalculation
    private

    def shipping_cost(distance)
      return DEFAULT_DELIVERY_COST if distance == DEFAULT_DELIVERY_COST

      FIX_RATE + (distance * RATE_PER_MILE.to_f) +
        ((@order_weight.to_f * 0.001) * RATE_PER_TONE.to_f) + (@order_price.to_f * INSURANCE_RATE.to_f / 100)
    end
  end
end
