require 'spec_helper'

describe Venue do
  it { should have_and_belong_to_many :venue_types }
  it { should have_and_belong_to_many :keywords }
  it { should belong_to :neighbourhood }
  it { should have_many(:categories).through(:keywords) }
  it { should have_many :photos }
  it { should validate_presence_of :name }

  describe 'an instance' do
    it 'gets geocoded before_save if full address is available' do
      venue = create(:venue,
        :address => '130 Heffernan Ave.', :city => 'Calexico',
        :state => 'California', :country => 'United States',
        :zip => '92231'
      )
      expect(venue).to be_geocoded
    end

    it 'does not get geocoded if full address is missing' do
      venue = create(:venue)
      expect(venue).to_not be_geocoded
    end
  end

  describe '#full_address' do
    it 'concatenates :address, :city, :state, :country and :zip values' do
      venue = create(:venue,
        :address => '130 Heffernan Ave.', :city => 'Calexico',
        :state => 'California', :country => 'United States',
        :zip => '92231'
      )
      expect(venue.full_address).to eq("130 Heffernan Ave., Calexico, California, 92231, United States")
    end
  end

  describe 'scopes' do
    let!(:cheap) { create(:keyword, :name => 'Cheap') }
    let!(:awesome) { create(:keyword, :name => 'Awesome') }
    let!(:brooklyn) { create(:neighbourhood, :name => 'Brooklyn') }
    let!(:bronx) { create(:neighbourhood, :name => 'Bronx')}
    let!(:venue) { create(:venue, :name => 'Star Games', :neighbourhood => brooklyn, :keywords => [cheap, awesome]) }
    let!(:other_venue) { create(:venue, :name => 'Starbucks', :neighbourhood => bronx, :keywords => [cheap]) }
    let!(:untagged) { create(:venue, :neighbourhood => bronx) }

    describe '.in_neighbourhood' do
      it 'returns a list of Venues in a given Neighbourhood' do
        venues = Venue.in_neighbourhood(brooklyn.id)

        expect(venues).to include(venue)
        expect(venues).to_not include(other_venue)
      end
    end

    describe '.match_name' do
      it 'returns a list of Venues with a given :name' do
        venues = Venue.match_name('star')
        expect(venues).to include(venue)
        expect(venues).to include(other_venue)
        expect(venues).to_not include(untagged)
      end
    end

    describe '.featured' do
      it 'returns a list of Venues marked as featured' do
        featured_venue = create(:venue, :featured => true)
        expect(Venue.featured).to include(featured_venue)
      end

      it 'does not return Venues not marked as featured' do
        venue = create(:venue)
        expect(Venue.featured).to_not include(venue)
      end
    end

    describe '.sort_by_keywords' do
      it 'sorts Venues by counting matches against given keyword(s) id(s)'
    end
  end
end