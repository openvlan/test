class TripsQuery
  def list(start_datetime:, end_datetime:, status:, network_id: nil)
    query(
      network_id: network_id,
      start_datetime: start_datetime,
      end_datetime: end_datetime,
      status: status
    )
  end

  private

  def query(start_datetime:, end_datetime:, status:, network_id:)
    trip_query = general_query(
      start_datetime: start_datetime,
      end_datetime: end_datetime
    )

    trip_query = trip_query.where(network_id: network_id) if network_id.present?
    trip_query.where(
      status: status
    ).order(
      status: :asc,
      start_datetime: :asc
    )
  end

  def general_query(start_datetime:, end_datetime:)
    trips_searched(
      start_datetime: start_datetime,
      end_datetime: end_datetime
    ).select(
      "trips.id, trips.status, trips.steps, trips.shipper_id,
       trips.trip_number, trips.comments, trips.amount,
       trips.distance, trips.start_datetime"
    )
  end

  def trips_searched(start_datetime:, end_datetime:)
    Trip.with_list_joins
        .where('start_datetime >= ?', start_datetime)
        .where('start_datetime <= ?', end_datetime)
  end
end
