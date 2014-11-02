class KeywordSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :name, :category_id

  has_many :venue_types
end
