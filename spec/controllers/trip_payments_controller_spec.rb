require 'rails_helper'

RSpec.describe TripPaymentsController do
  describe '#create' do
    it 'returns not found when trip id is invalid' do
      mock_current_user(build(:user))

      trip_id = 'ababab'

      post 'create', params: { trip_id: trip_id }
      expect(response).to have_http_status :not_found
    end
  end
end
