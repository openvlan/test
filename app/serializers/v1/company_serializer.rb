class V1::CompanySerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id, :name, :ein, :max_distance_from_base,
             :usdot, :mc_number, :mc_number_type, :sacs_number
end
