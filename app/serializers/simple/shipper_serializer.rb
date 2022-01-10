class Simple::ShipperSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id,
             :first_name,
             :last_name,
             :avatar_url

  def avatar_url
    ''
  end
end
