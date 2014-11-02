require 'spec_helper'

describe Neighbourhood do
  it { should have_many :venues }
  it { should validate_presence_of :name }

  describe '.search scope' do
    let(:bronx) { create(:neighbourhood, :name => 'Bronx') }
    let(:brooklyn) { create(:neighbourhood, :name => 'Brooklyn') }

    it 'returns a list of Neighbourhoods that match a provided string' do
      expect(Neighbourhood.search('bro')).to include(bronx)
      expect(Neighbourhood.search('bro')).to include(brooklyn)

      expect(Neighbourhood.search('broo')).to include(brooklyn)
      expect(Neighbourhood.search('broo')).to_not include(bronx)
    end
  end
end