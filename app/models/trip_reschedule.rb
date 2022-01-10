class TripReschedule
  def initialize(trip)
    @trip = trip
  end

  def run
    new_trip = setup_new_trip
    Trip.skip_callback(:create, :before, :calculate_distance, raise: false)
    new_trip.save!
    notice_cancellation_with_enough_time(new_trip)
    new_trip
  end

  def notice_cancellation_with_enough_time(new_trip)
    TripMailer.notify_logistics_trip_reschedule(@trip, new_trip).deliver
    @trip.orders.each do |order|
      TripMailer.buyer_notice_shipper_changed(order.marketplace_order_id).deliver
      TripMailer.seller_notice_shipper_changed(order.marketplace_order_id).deliver
    end
  end

  def reschedule_datetime_from(datetime)
    reschedule_hours_diff_from_wday = {
      0 => 24,
      1 => 24,
      2 => 24,
      3 => 24,
      4 => 24,
      5 => 72,
      6 => 48
    }

    datetime + reschedule_hours_diff_from_wday[datetime.wday].hours
  end

  private

  def setup_new_trip
    new_trip = @trip.dup
    new_trip.old_trip_number = @trip.trip_number
    new_trip.start_datetime = reschedule_datetime_from(@trip.start_datetime)
    new_trip.status = :broadcasting
    new_trip.shipper = nil
    new_trip.trip_number = nil
    @trip.orders.each do |o|
      new_trip.orders << o
    end
    new_trip
  end
end
