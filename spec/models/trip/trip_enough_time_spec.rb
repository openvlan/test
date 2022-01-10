# == Schema Information
#
# Table name: trip_assignments
#
#  id                   :bigint           not null, primary key
#  state                :string
#  trip_id              :uuid
#  shipper_id           :uuid
#  created_at           :datetime
#  notification_payload :jsonb
#  notified_at          :datetime
#  closed_at            :datetime
#  network_id           :string
#

require 'rails_helper'

RSpec.describe TripEnoughTime, type: :model do
  context 'on any day of week' do
    let(:sample_week) {
      [
        DateTime.new(2021, 7, 18, 12, 0, 0).utc,
        DateTime.new(2021, 7, 19, 12, 0, 0).utc,
        DateTime.new(2021, 7, 20, 12, 0, 0).utc,
        DateTime.new(2021, 7, 21, 12, 0, 0).utc,
        DateTime.new(2021, 7, 22, 12, 0, 0).utc,
        DateTime.new(2021, 7, 23, 12, 0, 0).utc,
        DateTime.new(2021, 7, 24, 12, 0, 0).utc
      ]
    }

    it 'check at least 24 hs before is enough' do
      sample_week.each do |target_day|
        allow(Time).to receive_messages(now: target_day - 25.hours)
        expect(TripEnoughTime.enough?(target_day)).to be true
      end
    end

    it 'check less then 24 hs before is NOT enough' do
      sample_week.each do |target_day|
        allow(Time).to receive_messages(now: target_day - 23.hours)
        expect(TripEnoughTime.enough?(target_day)).to be false
      end
    end
  end
end
