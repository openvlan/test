class OrdersQuery
  def trip_planner(params)
    base_orders = Order.all
    base_orders = base_orders.where(network_id: params[:network_id]) if params.key? :network_id
    order_ids = (orders_without_trips_query.pluck(:id) + (orders_with_canceled_trips_query(base_orders)).pluck(:id))
    base_orders.where(id: order_ids)
  end

  def orders_without_trips_query
    Order.left_joins(:trip_orders).where(trip_orders: { trip_id: nil })
         .distinct
  end

  def orders_with_canceled_trips_query(base_query)
    orders_with_canceled_trips = base_query.where('trip_orders.trip_id IS NOT NULL')
                                           .joins(:trips)
                                           .where(trips: { status: :canceled })
                                           .distinct
                                           .pluck :id

    orders_with_no_canceled_trips = base_query.where('trip_orders.trip_id IS NOT NULL')
                                              .joins(:trips)
                                              .where.not(trips: { status: :canceled })
                                              .distinct
                                              .pluck :id

    r = orders_with_canceled_trips - orders_with_no_canceled_trips

    base_query.where(id: r)
  end
end
