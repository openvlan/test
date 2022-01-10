# == Schema Information
#
# Table name: orders
#
#  id              :uuid             not null, primary key
#  receiver_id     :uuid
#  expiration      :date
#  amount          :decimal(12, 4)   default(0.0)
#  bonified_amount :decimal(12, 4)   default(0.0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  extras          :jsonb
#  network_id      :string
#  with_delivery   :boolean
#  giver_ids       :text             default([]), is an Array
#

require 'rails_helper'

RSpec.describe Order, type: :model do
  it { is_expected.to respond_to(:total_amount).with(0).argument }
end
