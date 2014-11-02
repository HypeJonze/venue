class VenueSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :name, :description, :address, :address_secondary,
    :intersection, :city, :state, :country, :zip, :contact_phone, :contact_email,
    :food, :music, :dress_code, :entry_fee, :style, :crowd, :specialty,
    :specials, :price_range, :parking, :hours, :date,
    :enabled, :featured, :created_at, :updated_at, :logo, :neighbourhood_id,
    :latitude, :longitude, :full_address, :googlemap_url

  has_many :keywords
  has_many :venue_types
  has_one :neighbourhood
  has_many :photos

  def logo
    if !object.logo.nil? and !object.logo.url.nil?
      path_to_file = object.logo.url.split('/')
      filename = path_to_file.pop
      {
        :versions => ["thumb_", "small_", "large_"],
        :filename => filename,
        :path => path_to_file.join('/') + "/"
      }
    end
  end

  def googlemap_url
    address = [
      object.address, object.address_secondary, object.city,
      object.state, object.zip, object.country
    ].compact

    Geocoder::Lookup::Google.new.map_link_url(address)
  end

end
