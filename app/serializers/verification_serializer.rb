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

class VerificationSerializer < ActiveModel::Serializer
  attributes :id, :type, :information, :verified, :expired, :expire, :expire_at, :responsible, :created_at

  def verified
    object.verified?
  end

  def expired
    object.expired?
  end
end
