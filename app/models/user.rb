class User < UserApiResource
  ROLES = %i[
    admin
    seller
    buyer
    driver
  ].freeze

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.create_driver(attributes)
    response = post(:create_driver, attributes)
    new(JSON.parse(response.body)['user'], true)
  end

  def update_driver_network_id(network_id)
    post(:update_driver_network_id, { network_id: network_id })
  end

  ROLES.map(&:to_s).each do |role_name|
    define_method("#{role_name}?".to_sym) { role? role_name }
  end

  def can_operate_on_network_id?(network_id)
    operable_network_ids.include? network_id
  end

  private

  def role?(role_name)
    roles.any? { |r| r.name.underscore.to_sym == role_name.to_sym }
  end
end
