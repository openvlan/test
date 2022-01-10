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

require 'rails_helper'

RSpec.describe Verification, type: :model do
  it { is_expected.to belong_to(:verificable) }

  it { is_expected.to respond_to(:type).with(0).argument }
  it { is_expected.to respond_to(:type=).with(1).argument }
  it { is_expected.to respond_to(:information).with(0).argument }
  it { is_expected.to respond_to(:information=).with(1).argument }

  it { is_expected.to respond_to(:verified?).with(0).argument }
  it { is_expected.to respond_to(:expired?).with(0).argument }
  it { is_expected.to respond_to(:responsible).with(0).argument }
end
