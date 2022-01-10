module DeliveryCosts
  class Free < DefaultCalculation
    private

    def shipping_cost(_distance)
      0
    end
  end
end
