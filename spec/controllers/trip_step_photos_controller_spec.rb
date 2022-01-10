require 'rails_helper'

RSpec.describe TripStepPhotosController do
  before(:each) do
    allow_any_instance_of(Shipper).to receive(:set_user_role_network_id) { nil }
  end

  let(:current_user) { build(:user) }
  let(:trip) { create(:trip_with_shipper) }
  let(:another_trip) {
    create(:trip, shipper: create(:shipper, user_id: 'e0ed4771-a731-4ada-9c6f-c95aaff5c584', company: create(:company)))
  }
  let(:photo_signed_id) do
    ActiveStorage::Blob.create_after_upload!(
      io: File.open(Rails.root.join('spec', 'support', 'assets', 'illusion.jpg'), 'rb'),
      filename: 'illusion.jpg',
      content_type: 'image/jpeg'
    ).signed_id
  end

  before(:each) do
    mock_current_user(current_user)
    allow_any_instance_of(Shipper).to receive(:network_id) { 1 }
    allow_any_instance_of(Address).to receive(:assign_closest_network) { 1 }
    allow(trip).to receive(:log_photo_uploaded) { nil }
    allow(another_trip).to receive(:log_photo_uploaded) { nil }
  end

  describe '#create' do
    it 'creates a valid trip step photo' do
      time_before_create = Time.now
      step_index = 5
      post 'create', params: {
        file: photo_signed_id,
        trip_id: trip.id,
        step_index: step_index,
        gps_coordinates: 'POINT (1 1)'
      }
      expect(response).to have_http_status :created
      trip_step_photo = TripStepPhoto.last
      expect(trip_step_photo.trip_id).to(eq(trip.id))
      expect(trip_step_photo.shipper_id).to(eq(trip.shipper_id))
      expect(trip_step_photo.step_index).to(eq(step_index))
      expect(trip_step_photo.gps_coordinates.to_s).to(eq('POINT (1.0 1.0)'))
      expect(trip_step_photo.created_at).to be > time_before_create
      expect(trip_step_photo.updated_at).to be > time_before_create
      expect(trip_step_photo.file.signed_id).to(eq(photo_signed_id))

      trip = trip_step_photo.trip
      expect(trip.trip_status_change_audits.last.event).to eq('Photo uploaded')
      msg = "#{current_user.email} uploaded a photo. <a href='#{trip_step_photo.url}'>View Photo</a>"
      expect(trip.trip_status_change_audits.last.comments).to eq(msg)
    end

    it 'requires a file' do
      expect do
        post 'create', params: {
          trip_id: trip.id,
          step_index: 2,
          gps_coordinates: 'POINT (1 3)'
        }
      end.to(raise_error(ActiveRecord::RecordInvalid, 'Validation failed: File must be attached'))
    end

    it 'requires a correct file signed_id' do
      expect do
        post 'create', params: {
          file: 'msmsmsm',
          trip_id: trip.id,
          step_index: 7,
          gps_coordinates: 'POINT (2 1)'
        }
      end.to(raise_error(ActiveSupport::MessageVerifier::InvalidSignature))
    end

    it 'requires a trip' do
      expect do
        post 'create', params: {
          file: photo_signed_id,
          step_index: 2,
          gps_coordinates: 'POINT (1 3)'
        }
      end.to(raise_error(ActiveRecord::RecordNotFound, "Couldn't find Trip without an ID"))
    end

    it 'requires a step index' do
      expect do
        post 'create', params: {
          file: photo_signed_id,
          trip_id: trip.id,
          gps_coordinates: 'POINT (1 3)'
        }
      end.to(raise_error(ActiveRecord::NotNullViolation))
    end

    it 'allows null gps coordinates' do
      expect do
        post 'create', params: {
          file: photo_signed_id,
          trip_id: trip.id,
          step_index: 6,
          gps_coordinates: nil
        }
      end.not_to(raise_error)
    end
  end

  describe '#destroy' do
    it 'deletes a trip step photo' do
      post 'create', params: {
        file: photo_signed_id,
        trip_id: trip.id,
        step_index: 6,
        gps_coordinates: 'POINT (1 1)'
      }
      trip_step_photo = TripStepPhoto.last
      post 'destroy', params: { id: trip_step_photo.id }
      expect(response).to have_http_status :ok
      expect do
        TripStepPhoto.find(trip_step_photo.id)
      end.to(raise_error(ActiveRecord::RecordNotFound))
    end

    it 'throws error when given an invalid id' do
      expect do
        post 'destroy', params: { id: 999 }
      end.to(raise_error(ActiveRecord::RecordNotFound))
    end
  end

  describe '#index' do
    it 'shows all trip step photos for a trip' do
      post 'create', params: {
        file: photo_signed_id,
        trip_id: trip.id,
        step_index: 1,
        gps_coordinates: 'POINT (0.5 1.4)'
      }
      post 'create', params: {
        file: photo_signed_id,
        trip_id: trip.id,
        step_index: 3,
        gps_coordinates: 'POINT (0.3 2.5)'
      }
      post 'create', params: {
        file: photo_signed_id,
        trip_id: another_trip.id,
        step_index: 5,
        gps_coordinates: 'POINT (0.4 4.5)'
      }
      get 'index', params: { trip_id: trip.id }
      expect(response).to have_http_status :ok
      expect(JSON.parse(response.body)).to(
        match(
          'trip_step_photos' => [
            {
              'id' => an_instance_of(Integer),
              'trip_id' => an_instance_of(String),
              'shipper' => {
                'id' => an_instance_of(String),
                'first_name' => an_instance_of(String),
                'last_name' => an_instance_of(String),
                'avatar_url' => ''
              },
              'file' => {
                'id' => an_instance_of(Integer),
                'url' => an_instance_of(String),
                'position' => 0,
                'signed_id' => an_instance_of(String)
              },
              'step_index' => 1,
              'gps_coordinates' => {
                'type' => 'Point',
                'coordinates' => [0.5, 1.4]
              },
              'created_at' => an_instance_of(String),
              'updated_at' => an_instance_of(String)
            },
            {
              'id' => an_instance_of(Integer),
              'trip_id' => an_instance_of(String),
              'shipper' => {
                'id' => an_instance_of(String),
                'first_name' => an_instance_of(String),
                'last_name' => an_instance_of(String),
                'avatar_url' => ''
              },
              'file' => {
                'id' => an_instance_of(Integer),
                'url' => an_instance_of(String),
                'position' => 0,
                'signed_id' => an_instance_of(String)
              },
              'step_index' => 3,
              'gps_coordinates' => {
                'type' => 'Point',
                'coordinates' => [0.3, 2.5]
              },
              'created_at' => an_instance_of(String),
              'updated_at' => an_instance_of(String)
            }
          ]
        )
      )
    end
  end
end
