require 'spec_helper'

describe Keyword do
  it { should have_and_belong_to_many :venue_types }
  it { should belong_to :category }
  it { should validate_presence_of :name }

  describe '.search scope' do
    let(:lively) { create(:keyword, :name => 'Lively') }
    let(:live_music) { create(:keyword, :name => 'Live Music') }

    it 'returns a list of Keywords that match a provided string' do
      expect(Keyword.search('live')).to include(lively)
      expect(Keyword.search('live')).to include(live_music)

      expect(Keyword.search('lively')).to include(lively)
      expect(Keyword.search('lively')).to_not include(live_music)
    end
  end
end