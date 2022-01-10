class StartDatetimeValidator < ActiveModel::Validator
  def validate(trip)
    start_datetime = trip.start_datetime_in_timezone

    trip.errors.add(:start_datetime, 'must round to 15 minutes') unless rounds_to_15_minutes(start_datetime)

    min_step_closing_hour = min_step_closing_hour(trip, start_datetime)
    max_valid_start_hour = min_step_closing_hour - 1

    start_is_too_late = if start_datetime.hour == max_valid_start_hour
                          start_datetime.min != 0
                        else
                          start_datetime.hour > max_valid_start_hour
                        end

    if start_is_too_late
      trip.errors.add(
        :start_datetime,
        "must be at least 1 hour earlier than minimum closing time of locations in the route: #{min_step_closing_hour}:00"
      )
    end
  end

  private

  def min_step_closing_hour(trip, start_datetime)
    is_weekend = start_datetime.saturday? || start_datetime.sunday?
    marketplace_order_ids = trip.steps.map { |step| step['marketplace_order_id'] }.uniq
    marketplace_order_ids.map do |marketplace_order_id|
      order = Order.find_by(marketplace_order_id: marketplace_order_id)
      [order.warehouse_address_id, order.delivery_location_id].map do |address_id|
        open_hours = UserApiAddress.find(address_id).open_hours
        is_weekend ? open_hours.to_weekend : open_hours.to_workweek
      end.min
    end.min
  end

  def rounds_to_15_minutes(start_datetime)
    [0, 15, 30, 45].include?(start_datetime.min) && start_datetime.sec == 0
  end
end
