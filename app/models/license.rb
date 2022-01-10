class License < ApplicationRecord
  belongs_to :shipper
  audited associated_with: :shipper

  has_many_attached :photos, dependent: :destroy

  ATTRIBUTES = [:id, :number, :state, :expiration_date, { photos: %i[id url signed_id position _destroy] }] # rubocop:todo Style/MutableConstant

  validates :number, :state, :expiration_date, presence: true
  validates :number,
            format: { with: /\A[A-Za-z0-9\-*]*\z/, message: 'must only contain letters, numbers, hypens or asterisks' }
end
