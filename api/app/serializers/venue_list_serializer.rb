class VenueListSerializer < ActiveModel::Serializer
  self.root = false
  embed :ids, :include => true
  attributes :id, :name, :description, :address, :address_secondary,
    :intersection, :city, :state, :country, :zip, :contact_phone,
    :food, :music, :dress_code, :entry_fee, :style, :crowd, :specialty,
    :specials, :price_range, :parking, :hours, :date,
    :enabled, :featured, :created_at, :updated_at

  has_many :keywords
  has_one :neighbourhood
end