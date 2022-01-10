class V1::AuditSerializer < ActiveModel::Serializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :id,
             :action, :auditable_type, :audited_changes, :created_at, :username, :comment

  def username
    User.find_by(id: object.username)&.email
  end
end
