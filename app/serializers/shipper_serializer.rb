# == Schema Information
#
# Table name: shippers
#
#  id                   :uuid             not null, primary key
#  first_name           :string           not null
#  last_name            :string
#  gender               :string
#  birth_date           :date
#  email                :string           not null
#  phone_num            :string
#  photo                :string
#  active               :boolean          default(FALSE)
#  verified             :boolean          default(FALSE)
#  verified_at          :date
#  national_ids         :jsonb
#  gateway              :string
#  gateway_id           :string           not null
#  data                 :jsonb
#  minimum_requirements :jsonb
#  requirements         :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  password_digest      :string
#  token_expire_at      :integer
#  login_count          :integer          default(0), not null
#  failed_login_count   :integer          default(0), not null
#  last_login_at        :datetime
#  last_login_ip        :string
#  devices              :jsonb
#  network_id           :string
#

class ShipperSerializer < Simple::ShipperSerializer
  attributes :gender,
             :birth_date,
             :phone_num,
             :code,
             :photo,
             :active,
             :verified,
             :verified_at,
             :national_ids,
             :gateway,
             :gateway_id,
             :minimum_requirements,
             :requirements

  def code
    object.code
  end
end
