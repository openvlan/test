# Preview all emails at http://localhost:3030/rails/mailers/trip_mailer
class TripMailerPreview < ActionMailer::Preview
  def buyer_trip_canceled_email
    TripMailer.buyer_trip_canceled_email(Trip.last.steps.first)
  end

  def seller_trip_canceled_email
    TripMailer.seller_trip_canceled_email(Trip.last.steps.last)
  end

  def driver_trip_canceled_email
    Trip.last.update(shipper_id: last_active_shipper)
    TripMailer.driver_trip_canceled_email(Trip.first)
  end

  def driver_trip_refused_email
    trip = Trip.last
    trip.update(shipper_id: last_active_shipper.id)
    TripMailer.driver_trip_refused_email(Trip.last)
  end

  def driver_trip_assigned_email
    TripMailer.driver_trip_assigned_email(Shipper.where.not(user_id: nil).first)
  end

  def seller_trip_scheduled_email
    trip = Trip.last
    trip.update(shipper_id: last_active_shipper)
    TripMailer.seller_trip_scheduled_email(trip.steps.last,
                                           Time.now.tomorrow,
                                           last_active_shipper)
  end

  def buyer_trip_scheduled_email
    trip = Trip.last
    trip.update(shipper_id: last_active_shipper)
    TripMailer.buyer_trip_scheduled_email(trip.steps.first,
                                          Time.now.tomorrow,
                                          last_active_shipper)
  end

  def driver_is_on_the_way_seller_email
    trip = Trip.last
    trip.update(shipper_id: last_active_shipper)
    TripMailer.driver_is_on_the_way_buyer_email(trip.steps.first,
                                                last_active_shipper)
  end

  def driver_is_on_the_way_buyer_email
    trip = Trip.last
    trip.update(shipper_id: last_active_shipper)
    TripMailer.driver_is_on_the_way_buyer_email(trip.steps.first,
                                                last_active_shipper)
  end

  def order_delivered_seller_email
    TripMailer.order_delivered_seller_email(Trip.last.steps.first['marketplace_order_id'])
  end

  def order_delivered_buyer_email
    trip = Trip.last # rubocop:todo Lint/UselessAssignment
    TripMailer.order_delivered_buyer_email(Trip.last.steps.last['marketplace_order_id'])
  end

  def seller_notice_shipper_cancelled_near_delivery_time
    trip = Trip.last
    TripMailer.seller_notice_shipper_cancelled_near_delivery_time(trip.orders.first.marketplace_order_id)
  end

  def buyer_notice_shipper_cancelled_near_delivery_time
    trip = Trip.last
    TripMailer.buyer_notice_shipper_cancelled_near_delivery_time(trip.orders.first.marketplace_order_id)
  end

  def seller_notice_shipper_changed
    trip = Trip.last
    TripMailer.seller_notice_shipper_changed(trip.orders.first.marketplace_order_id)
  end

  def buyer_notice_shipper_changed
    trip = Trip.last
    TripMailer.buyer_notice_shipper_changed(trip.orders.first.marketplace_order_id)
  end

  def notify_logistics_trip_cancelled_near_starting_time
    trip = Trip.last
    TripMailer.notify_logistics_trip_cancelled_near_starting_time(trip)
  end

  def notify_logistics_trip_reschedule
    old_trip = Trip.first
    new_trip = Trip.last
    TripMailer.notify_logistics_trip_reschedule(old_trip, new_trip)
  end

  private

  def last_active_shipper
    @last_active_shipper ||= Shipper.active.last
  end
end
