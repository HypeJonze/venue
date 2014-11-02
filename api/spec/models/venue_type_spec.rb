require 'spec_helper'

describe VenueType do
  it { should have_and_belong_to_many :keywords }
  it { should have_and_belong_to_many :categories }
  it { should have_and_belong_to_many :venues }
  it { should validate_presence_of :name }

  describe '.search scope' do
    let(:ballroom) { create(:venue_type, :name => 'Ballroom') }
    let(:ballpark) { create(:venue_type, :name => 'Petco Ball Park') }

    it 'returns a list of VenueTypes that match a provided string' do
      expect(VenueType.search('ball')).to include(ballroom)
      expect(VenueType.search('ball')).to include(ballpark)

      expect(VenueType.search('room')).to include(ballroom)
      expect(VenueType.search('room')).to_not include(ballpark)
    end
  end
end