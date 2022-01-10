class Services::UserAuthenticationSerializer < UserSerializer # rubocop:todo Style/ClassAndModuleChildren
  attributes :password_digest
end
