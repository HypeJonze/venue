class Keyword < Base
  has_and_belongs_to_many :venue_types
  belongs_to :category

  validates :name, :presence => true
  validates :category, :presence => true

  scope :search, ->(query) { where(self.arel_table[:name].matches("%#{query}%")) }
end