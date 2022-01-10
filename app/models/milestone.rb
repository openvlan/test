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

class Milestone < ApplicationRecord
  module Name
    PICKUP = 'pickup'.freeze
    DELIVER = 'deliver'.freeze
    ALL = [PICKUP, DELIVER].freeze
  end

  attr_accessor :photos

  attribute :data, :jsonb, default: {}

  belongs_to :trip
  has_one :shipper, through: :trip

  validates_presence_of :name, :marketplace_order_id
  validates :name, inclusion: { in: Name::ALL }

  after_create :notify_creation_to_trip

  attribute :latlng
  def latlng
    return unless gps_coordinates

    gps_coordinates.coordinates.reverse.join(',')
  end

  private

  def notify_creation_to_trip
    trip.milestone_created(self)
  end
end
