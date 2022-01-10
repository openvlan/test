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

require 'rails_helper'

RSpec.describe Profile, type: :model do
  # Association test
  # ensure a profile record belongs to a single user record
  it { is_expected.to belong_to(:user) }
end
