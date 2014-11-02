require 'spec_helper'

describe API::V1::VenuesController do
  describe '#index' do
    let(:neighbourhood) { create(:neighbourhood, :name => 'Brooklyn') }

    before do
      50.times { create(:venue, :neighbourhood => neighbourhood) }
    end

    it 'returns a list of venues' do
      get 'index', :format => :json
      mssg = parse_json(response.body)
      expect(mssg).to_not be_empty
    end

    it 'accepts a :limit parameter' do
      get 'index', :limit => 10, :format => :json
      mssg = parse_json(response.body)
      expect(mssg.size).to eq(10)
    end

    it 'accepts an :offset parameter' do
      get 'index', :offset => 5, :format => :json
      expect(response.status).to eq(200)
    end

    context 'with query params' do
      let(:bronx) { create(:neighbourhood, :name => 'Bronx') }
      let!(:moderate) { create(:keyword, :name => 'Moderate') }
      let!(:jazz) { create(:keyword, :name => 'Jazz') }

      before do
        5.times { create(:venue, :neighbourhood => bronx) }
        3.times { create(:venue, :keywords => [jazz], :neighbourhood => bronx) }
        2.times { create(:venue, :keywords => [jazz, moderate]) }
        create(:venue, :name => 'Shiro Dreams of Sushi', :neighbourhood => bronx)
        create(:venue, :featured => true)
      end

      describe '?neighbourhood=' do
        it 'returns a collection of Venues in the selected Neighbourhood' do
          get 'index', :neighbourhood_id => bronx.id, :format => :json
          mssg = parse_json(response.body)
          expect(mssg.size).to eq(9)
        end
      end

      describe '?keywords=[]' do
        it 'returns a collection of Venues with the selected Keywords' do
          get 'index', :sort_keywords => "#{jazz.id},#{moderate.id}", :format => :json
          mssg = parse_json(response.body)
          expect(mssg.size).to eq(5)
        end
      end

      describe '?name=' do
        it 'returns a collection of Venues matching a given name' do
          get 'index', :search_name => 'Sushi', :format => :json
          mssg = parse_json(response.body)
          expect(mssg.size).to eq(1)
        end
      end

      describe '?neighbourhood=&sort_keywords=[]' do
        it 'returns a collection of Venues in the selected Neighbourhood with matched keywords' do
          get 'index', :neighbourhood_id => bronx.id, :sort_keywords => "#{jazz.id},#{moderate.id}",
            :format => :json
          mssg = parse_json(response.body)
          expect(mssg.size).to eq(3)
        end
      end

      describe '?featured=true' do
        it 'returns a collection of Venues marked as featured' do
          get 'index', :featured => true, :format => :json
          mssg = parse_json(response.body)
          expect(mssg.size).to eq(1)
        end
      end
    end
  end

  describe '#create' do
    let(:admin) { create(:admin) }
    
    context 'valid params' do
      before :each do
        request.headers['X-AuthToken'] = admin.api_token
        post 'create', :venue => { :name => 'Foo' }, :format => :json
      end

      it 'creates a new venue record' do
        expect(Venue.count).to eq(1)
      end

      it 'returns a venue object' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end
    end

    context 'invalid params' do
      before :each do
        post 'create', :venue => { :name => nil }, :format => :json
      end

      it 'does not create a new venue record' do
        expect(Venue.count).to eq(0)
      end

      it 'returns an validation error response' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
      end
    end
  end

  describe '#show' do
    let(:venue) { create(:venue) }

    context 'valid :id param' do
      it 'returns a venue object' do
        get 'show', :id => venue.id, :format => :json
        expect(response.status).to eq(200)
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end
    end

    context 'invalid :id param' do
      it 'returns a not found error response' do
        invalid_id = venue.id.to_i * rand(90)
        get 'show', :id => invalid_id, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
      end
    end
  end

  describe '#update' do
    let(:admin) { create(:admin) }
    let(:venue) { create(:venue) }
    let(:invalid_id)  { venue.id.to_i * rand(90) }

    before :each do
      request.headers['X-AuthToken'] = admin.api_token
    end

    context 'valid params' do
      it 'updates an existing venue record' do
        put 'update', :id => venue.id, :venue => { :name => 'Foo' }, :format => :json
        expect(response.status).to eq(204)
        venue.reload
        expect(venue.name).to eq('Foo')
      end
    end

    context 'invalid params' do
      it 'return a not found error if venue does not exist' do
        put 'update', :id => invalid_id, :venue => { :name => 'Foo' }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        venue.reload
        expect(venue.name).to_not eq('Foo')
      end

      it 'returns a validation error if params fail validation' do
        put 'update', :id => venue.id, :venue => { :name => nil }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        venue.reload
        expect(venue.name).to_not eq('Foo')
      end
    end
  end

  describe '#destroy' do
    let(:admin) { create(:admin) }
    let(:venue) { create(:venue) }
    let(:invalid_id)  { venue.id.to_i * rand(90) }

    before :each do
      request.headers['X-AuthToken'] = admin.api_token
    end

    it 'deletes a venue record if exists' do
      delete 'destroy', :id => venue.id, :format => :json
      expect(Venue.count).to eq(0)
    end

    it 'returns a not found error if venue does not exist' do
      delete 'destroy', :id => invalid_id, :format => :json
      expect(Venue.count).to eq(1)
      mssg = parse_json(response.body)
      expect(mssg.keys).to include("error")
    end
  end
end