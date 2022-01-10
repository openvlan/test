class TripPaymentQuery
  def list(search_text, network_id = nil)
    base = base_query(network_id)
    result = base
    result = add_search_text(base, base, search_text) if search_text.present?
    result.order('trips.start_datetime desc')
  end

  private

  # rubocop:disable Metrics/AbcSize
  def add_search_text(base_query, result, search_text)
    search_text.downcase.split.each do |text|
      result = base_query.where(*like('shippers.first_name', text))
                         .or(base_query.where(*like('shippers.last_name', text)))
                         .or(base_query.where(*like('confirmation_code', text)))
                         .or(base_query.where(*like('payment_email', text)))

      trip_number = integer(text)
      result = result.or(base_query.where(trips: { trip_number: trip_number })) if trip_number
    end
    result
  end
  # rubocop:enable Metrics/AbcSize

  def base_query(network_id)
    if network_id
      TripPayment.by_network_id(network_id).includes(:trip).left_joins(trip: :shipper)
    else
      TripPayment.includes(:trip).left_joins(trip: :shipper)
    end
  end

  def like(column, text)
    ["lower(#{column}) LIKE :l", { l: "%#{text}%" }]
  end

  def integer(search_text)
    Integer(search_text)
  rescue ArgumentError
    nil
  end
end
