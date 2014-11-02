class VenueTypeSerializer < ActiveModel::Serializer
  self.root = false
  
  attributes :id, :name
  has_many :categories
end
