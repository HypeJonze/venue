class Category < Base
  validates :name, :presence => true
  has_and_belongs_to_many :venue_types
  has_many :keywords

  scope :search, ->(query) { where(self.arel_table[:name].matches("%#{query}%")) }
end
