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

class MilestoneSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :latlng,
             :comments,
             :created_at
end
