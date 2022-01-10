# == Schema Information
#
# Table name: profiles
#
#  id         :uuid             not null, primary key
#  first_name :string
#  last_name  :string
#  user_id    :uuid             not null
#  extras     :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Profile < ApplicationRecord
  belongs_to :user

  attribute :extras, :jsonb, default: {}

  EXTRA_INFO = %w[
    cellphone
  ].freeze
  private_constant :EXTRA_INFO

  EXTRA_INFO.each do |extra_name|
    attribute :"#{extra_name}"

    define_method :"#{extra_name}" do
      (extras['info'] || {})[extra_name]
    end

    define_method :"#{extra_name}=" do |new_value|
      extras['info'] = extras['info'] || {}

      if new_value.present?
        extras['info'][extra_name] = new_value
      else
        extras['info'].delete(extra_name)
      end
    end
  end
end
