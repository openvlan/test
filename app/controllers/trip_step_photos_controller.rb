class TripStepPhotosController < ApplicationController
  def index
    render json: ActiveModelSerializers::SerializableResource.new(
      TripStepPhoto.where(trip_id: params[:trip_id]),
      each_serializer: TripStepPhotoSerializer
    ).as_json
  end

  def create
    trip = Trip.find(params[:trip_id])
    photo = TripStepPhoto.create!(
      create_trip_step_photo_params.merge(
        shipper_id: trip.shipper_id
      )
    )

    trip.log_photo_uploaded(current_user, photo)
    render status: :created
  end

  def destroy
    TripStepPhoto.destroy(params[:id])
    render status: :ok
  end

  private

  def create_trip_step_photo_params
    params.permit(
      :file,
      :trip_id,
      :step_index,
      :gps_coordinates
    )
  end
end
