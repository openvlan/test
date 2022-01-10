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

#  audited_id     :string
#  audited_type   :string
#  message        :string
#  field          :string
#  original_value :string
#  new_value      :string
#  user_id        :uuid
#  created_at     :datetime         not null
#  updated_at     :datetime         not null

class AuditSerializer < ActiveModel::Serializer
  attributes :id, :message, :field, :original_value, :new_value, :user_id, :author_email, :created_at

  def author_email
    return 'Not Fount Author' if object.author.nil?

    object.author.email
  end
end
