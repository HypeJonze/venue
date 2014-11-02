class UserSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :email, :api_token, :family_name, :given_name, :picture, :auth_via_mobile, :auth_via_web, :role, :created_at, :updated_at
end
