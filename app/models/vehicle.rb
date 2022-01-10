class Vehicle < ApplicationRecord
  attribute :extras, :jsonb, default: {}

  belongs_to :shipper
  audited associated_with: :shipper

  has_many :verifications, as: :verificable, dependent: :destroy

  has_many_attached :photos, dependent: :destroy

  ATTRIBUTES = [:id, :truck_type, :year, :make, :model, :color, :license_plate, :gross_vehicle_weight_rating,
                :insurance_provider, :has_liftgate, :has_forklift, { photos: %i[id url signed_id _destroy] }].freeze

  validates :truck_type, :gross_vehicle_weight_rating, presence: true

  enum truck_type: %i[semi_trailer dry_van refrigerated box liftgate jumbo_trailer flatbed]

  REFRIGERATED_INDEX = 2

  VERIFICATIONS = {
    license_plate: %w[register_date number state city],
    vehicle_title: %w[register_date owner_name state city],
    insurance: %w[register_date type company],
    security_kit: %w[medical fire],
    vtv: %w[required],
    free_traffic_ticket: %w[state]
  }.with_indifferent_access.freeze

  def to_s
    "#{truck_type.camelcase} #{make.camelcase} #{model.camelcase} #{license_plate}"
  end
end
