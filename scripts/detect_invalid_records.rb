def print_invalid_status_message(trip, marketplace_order)
  puts(
    "trip #{
trip.id
} has status #{
trip.status
} but marketplace order #{
marketplace_order.id
} with delivery method \"#{
marketplace_order.delivery_method
}\" has status #{
marketplace_order.status
}"
  )
end

Trip.all.each do |trip| # rubocop:todo Metrics/BlockLength
  marketplace_orders = trip.orders.map do |order|
    MarketplaceOrder.find(order.marketplace_order_id)
  rescue ActiveResource::ResourceNotFound
    puts "trip #{trip.id} has invalid marketplace_order_id #{order.marketplace_order_id}"
  end

  marketplace_orders.each do |marketplace_order|
    case trip.status
    when 'broadcasting', 'pending_driver_confirmation'
      if marketplace_order.delivery_by_tiko? && marketplace_order.status != MarketplaceOrder::Status::PICKUP_PENDING
        print_invalid_status_message(trip, marketplace_order)
      end
    when 'confirmed'
      if marketplace_order.delivery_by_tiko? && marketplace_order.status != MarketplaceOrder::Status::DELIVERY_SCHEDULED
        print_invalid_status_message(trip, marketplace_order)
      end
    when 'on_going'
      if marketplace_order.delivery_by_tiko?
        unless [MarketplaceOrder::Status::DELIVERY_SCHEDULED,
                MarketplaceOrder::Status::IN_DELIVERY].include?(marketplace_order.status)
          print_invalid_status_message(trip, marketplace_order)
        end
      else
        unless [MarketplaceOrder::Status::DELIVERY_SCHEDULED,
                MarketplaceOrder::Status::PICKUP_PENDING].include?(marketplace_order.status)
          print_invalid_status_message(trip, marketplace_order)
        end
      end
    end
  end
end

Shipper.all.each do |shipper|
  not_found = false
  begin
    not_found = true if shipper.user.blank?
  rescue StandardError
    not_found = true
  end
  puts "couldn't find user for shipper #{shipper.id}" if not_found
end
