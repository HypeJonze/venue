class Venue < Base
  validates :name, :presence => true
  
  has_and_belongs_to_many :venue_types
  has_and_belongs_to_many :keywords
  has_many :categories, :through => :keywords
  has_many :photos
  belongs_to :neighbourhood

  scope :for_user, ->(user_id) { where(:user_id => user_id) }

  scope :in_neighbourhood, ->(neighbourhood_id) { where(:neighbourhood_id => neighbourhood_id) }

  scope :of_venue_type, ->(venue_type_id) { where(:venue_types => {:id => venue_type_id}) }

  scope :match_name, ->(name) { where(self.arel_table[:name].matches("%#{name}%")) }
  scope :featured, -> { where(:featured => true) }

  scope :with_at_least_one_keyword, ->(kwd_ids) {
    joins(:keywords).select("venues.*, (SELECT COUNT(keywords_venues.venue_id) " +
      "FROM keywords_venues WHERE keywords_venues.venue_id = venues.id AND " +
      "keywords_venues.keyword_id IN (#{kwd_ids.join(',')})) AS kwd_count"
    ).where(
      "keywords_venues.keyword_id IN (?)", kwd_ids
    ).group("venues.id").order("kwd_count DESC, venues.name ASC")
  }
  
  mount_uploader :logo, LogoUploader
  geocoded_by :full_address
  after_validation :geocode, :if => ->(obj) { obj.address.present? and obj.address_changed? }

  def full_address
    [
      address, address_secondary, city, state, zip, country
    ].compact.join(', ')
  end

  def geocoded?
    latitude && longitude
  end
end
