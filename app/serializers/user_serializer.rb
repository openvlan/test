class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :email,
             :active,
             :confirmed,
             :last_login_ip,
             :last_login_at,
             :token_expire_at,
             :institution_id,
             :profile

  def profile
    if profile = object.profile # rubocop:todo Lint/AssignmentInCondition
      {
        first_name: profile.first_name,
        last_name: profile.last_name,
        cellphone: profile.cellphone
      }
    else
      {
        first_name: nil,
        last_name: nil,
        cellphone: nil
      }
    end
  end
end
