class VenueNestedSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :name, :description, :address, :address_secondary,
    :intersection, :city, :state, :country, :zip, :contact_phone,
    :food, :music, :dress_code, :entry_fee, :style, :crowd, :specialty,
    :specials, :price_range, :parking, :hours, :date,
    :enabled, :featured
end