# == Schema Information
#
# Table name: verifications
#
#  id               :bigint           not null, primary key
#  verificable_type :string
#  verificable_id   :uuid
#  data             :jsonb
#  verified_at      :datetime
#  verified_by      :uuid
#  expire           :boolean
#  expire_at        :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  network_id       :string
#

class Verification < ApplicationRecord
  self.inheritance_column = 'type_of'

  attribute :data, :jsonb, default: {}

  validates_presence_of :data

  belongs_to :verificable, polymorphic: true, optional: true

  DATA = %w[
    type
    information
  ].freeze
  private_constant :DATA

  DATA.each do |data_key|
    attribute :"#{data_key}"

    define_method :"#{data_key}" do
      _data = (data || {}) # rubocop:todo Lint/UnderscorePrefixedVariableName
      _data[data_key]
    end

    define_method :"#{data_key}=" do |new_value|
      data[data_key] = new_value
    end
  end

  def verified?
    not verified_at.blank? # rubocop:todo Style/Not
  end

  def expired?
    !!expire && expire_at < Time.now
  end

  def responsible
    return unless verified?

    User.find_by(id: verified_by)
  end
end
