class VenueType < Base
  validates :name, :presence => true

  has_and_belongs_to_many :keywords
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :venues

  scope :search, ->(query) { where(self.arel_table[:name].matches("%#{query}%")) }
end
