require 'spec_helper'

describe API::V1::SearchController do
  describe '#metadata' do
    it 'returns a collection of VenueTypes and related records' do
      get 'metadata', :format => :json
      mssg = parse_json(response.body)

      expect(mssg.keys).to include("venue_types")
    end
  end

  describe '#results' do
    let!(:neighbourhood) { create(:neighbourhood) }
    let!(:venue_type) { create(:venue_type) }
    let!(:venue) { create(:venue, :venue_types => [venue_type], :neighbourhood => neighbourhood) }

    it 'requires a :neighbourhood_id param' do
      get 'results', :venue_type_id => venue_type.id, :format => :json
      mssg = parse_json(response.body)
      expect(mssg.keys).to include("error")
      expect(mssg.values).to include("You must provide both a :neighbourhood_id and :venue_type_id params.")
    end

    it 'requires a :venue_type_id param' do
      get 'results', :neighbourhood_id => neighbourhood.id, :format => :json
      mssg = parse_json(response.body)
      expect(mssg.keys).to include("error")
      expect(mssg.values).to include("You must provide both a :neighbourhood_id and :venue_type_id params.")
    end

    it 'returns a collection of Venues and related data' do
      get 'results', :neighbourhood_id => neighbourhood.id,
        :venue_type_id => venue_type.id, :format => :json
      mssg = parse_json(response.body)
      expect(mssg.keys).to include("search")
    end
  end
end