module Trips
  class Update
    prepend Service::Base

    def initialize(trip, trip_params)
      @trip = trip
      @trip_params = trip_params
    end

    def call
      update_trip
    end

    private

    def update_trip
      update_trip_params

      if @trip_params[:shipper_id].present?
        @trip.assign_driver!
        TripMailer.driver_trip_assigned_email(@trip.shipper).deliver
      end

      Notifications::Push.new(@trip, true).call if @trip.shipper_id.present?

      @trip
    end

    def update_trip_params
      start_datetime_params = @trip_params.extract!(:start_date_string, :start_time_string)
      @trip.update_timezone_name
      @trip.set_start_datetime(
        start_datetime_params[:start_date_string],
        start_datetime_params[:start_time_string]
      )
      @trip.update(@trip_params)
      @trip.save!
    end
  end
end
