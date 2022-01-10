class UpdateTripStatus
  prepend Service::Base

  def initialize(milestone)
    @milestone = milestone
    @milestone_name = @milestone.name.downcase
    @trip = @milestone.trip
  end

  def call
    return unless %w[init completed].include?(@milestone_name)

    update_trip_status
  end

  private

  def update_trip_status
    @trip.assign_attributes(status: trip_status)

    return @trip if @trip.save

    errors.add_multiple_errors(@trip.errors.messages) && nil
  end

  def trip_status
    @milestone_name == 'completed' ? 'completed' : 'on_going'
  end
end
