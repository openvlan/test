module Trips
  class Milestone
    prepend Service::Base

    def initialize(trip, milestone_params)
      @trip = trip
      @milestone_params = milestone_params
    end

    def call
      trip_milestone
    end

    private

    def trip_milestone # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      begin
        Raven.capture do
          ActiveRecord::Base.transaction do
            trip_photos = []
            @milestone_params[:files].each do |file|
              trip_photos << TripStepPhoto.create!(
                file: file,
                trip_id: @trip.id,
                shipper_id: @trip.shipper_id,
                step_index: @milestone_params[:step_index],
                gps_coordinates: @milestone_params[:gps_coordinates]
              )
            end
            @milestone = @trip.milestones.create!(@milestone_params.except(:step_index,
                                                                           :files).merge(photos: trip_photos))

            Trips::Emails::OrderDelivered.new(@milestone.marketplace_order_id).call if @milestone.name.eql? 'deliver'

            send_email

            update_marketplace_order_status
          end
        end
      rescue ActiveResource::TimeoutError
        # usually when this happens the request executed correctly
      rescue ActiveRecord::RecordInvalid => e
        return errors.add_multiple_errors(exception_errors(e))
      rescue StandardError => e
        errors.add(:error, e.exception)
      end
      @trip
    end

    def send_email
      return if @trip.steps[@trip.milestones.count].nil?

      Trips::Emails::DriverIsOnTheWay.new(
        @trip.steps[@trip.milestones.count],
        @trip.shipper
      ).call
    end

    def update_marketplace_order_status
      marketplace_order = MarketplaceOrder.find(@milestone.marketplace_order_id)
      case @milestone.name
      when ::Milestone::Name::PICKUP
        marketplace_order.driver_pickup
      when ::Milestone::Name::DELIVER
        marketplace_order.deliver
      end
    end
  end
end
