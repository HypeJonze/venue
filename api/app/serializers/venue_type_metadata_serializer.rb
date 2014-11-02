class VenueTypeMetadataSerializer < ActiveModel::Serializer
  embed :ids, :include => true
  
  attributes :id, :name
  has_many :categories
  has_many :keywords
end