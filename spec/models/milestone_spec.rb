# == Schema Information
#
# Table name: milestones
#
#  id              :bigint(8)        not null, primary key
#  trip_id         :uuid
#  name            :string
#  comments        :text
#  data            :jsonb
#  gps_coordinates :geography({:srid point, 4326
#  created_at      :datetime
#  network_id      :string
#

require 'rails_helper'

RSpec.describe Milestone, type: :model do
  it { is_expected.to belong_to(:trip) }
  it { is_expected.to have_one(:shipper).through(:trip) }

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to respond_to(:latlng).with(0).argument }

  context 'instance with values,' do
    subject { build(:milestone) }

    skip 'latlng have to match coordinates' do
      expect(subject.latlng).to eq(subject.gps_coordinates.coordinates.reverse.join(','))
    end
  end
end
