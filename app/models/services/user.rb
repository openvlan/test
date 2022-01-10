module Services
  class User < Services::UserService
    include RoleModel

    attributes :id, :email, :username, :active, :confirmed, :last_login_at, :profile, :tdu_accepted
  end
end
