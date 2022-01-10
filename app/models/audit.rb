# == Schema Information
#
# Table name: audits
#
#  id             :uuid             not null, primary key
#  audited_id     :string
#  audited_type   :string
#  message        :string
#  field          :string
#  original_value :string
#  new_value      :string
#  user_id        :uuid
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Audit < ApplicationRecord
  belongs_to :audited, polymorphic: true
  validates :user_id, presence: { message: 'Se debe especificar un id de usuario' }
  validates :original_value, presence: { message: 'Se debe especificar un valor original' }
  validates :new_value, presence: { message: 'Se debe especificar el valor nuevo' }
  validates :field, presence: { message: 'Se debe especificar el campo de los valores' }
  validate :valid_audited_type

  module Models
    TRIP = 'Trip'.freeze
    ORDER = 'Order'.freeze
  end

  ALLOWED_MODELS = [Models::TRIP, Models::ORDER].freeze

  def author
    Services::User.find(user_id)
  end

  private

  def valid_audited_type
    model_is_allowed = ALLOWED_MODELS.include?(audited_type)
    errors.add(:model, 'El modelo de la auditoría no es válido') unless model_is_allowed
  end
end
