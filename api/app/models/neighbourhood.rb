class Neighbourhood < Base
  has_many :venues
  validates :name, :presence => true

  scope :search, ->(query) { where(self.arel_table[:name].matches("%#{query}%")) }
end
