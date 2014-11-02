require 'spec_helper'

describe Category do
  it { should have_and_belong_to_many :venue_types }
  it { should have_many :keywords }
  it { should validate_presence_of :name }

  describe '.search scope' do
    let(:car_wash) { create(:category, :name => 'Car Wash') }
    let(:carpet_cleaners) { create(:category, :name => 'Carpet Cleaner') }

    it 'returns a list of Categories that match a provided string' do
      expect(Category.search('car')).to include(car_wash)
      expect(Category.search('car')).to include(carpet_cleaners)

      expect(Category.search('carpet')).to include(carpet_cleaners)
      expect(Category.search('carpet')).to_not include(car_wash)
    end
  end
end