module Domain
  class AuthResponse
    include ActiveModel::Model

    attr_accessor :id, :username, :email, :active, :confirmed, :last_login_ip, :last_login_at, :token_expire_at,
                  :seller_company, :buyer_company, :profile,
                  :last_order_at, :tdu_accepted, :confirmed_phone, :is_main_user,
                  :first_name, :last_name, :roles, :code, :full_name, :operable_network_ids

    def can_operate_on_network_id?(network_id)
      operable_network_ids.include? network_id
    end
  end
end
