class Company < ApplicationRecord
  audited
  has_associated_audits

  has_one :address, dependent: :destroy
  has_many :shippers

  accepts_nested_attributes_for :address, allow_destroy: true

  validates_length_of :sacs_number, maximum: 50, allow_blank: true
  validates_length_of :ein, is: 9, optional: true, allow_blank: true
  validates_numericality_of :max_distance_from_base, greater_than: 0.0, allow_blank: true

  enum mc_number_type: %i[no MC FF MX]

  def network_id
    address&.network_id
  end
end
