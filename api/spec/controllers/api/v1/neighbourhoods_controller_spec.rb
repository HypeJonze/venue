require 'spec_helper'

describe API::V1::NeighbourhoodsController do
  describe '#index' do
    before do
      create_list(:neighbourhood, 50)
    end

    it 'returns a list of neighbourhoods' do
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

    it 'accepts a :search parameter' do
      get 'index', :search => 'Food', :format => :json
      expect(response.status).to eq(200)
    end

    context 'params[:search]' do
      before do
        @bronx = create(:neighbourhood, :name => 'Bronx')
      end

      it 'filters to Neighbourhoods that match a search string' do
        get 'index', :search => 'bron', :format => :json
        assigns(:neighbourhoods).should include(@bronx)
      end
    end
  end

  describe '#create' do
    context 'valid params' do
      let(:admin) { create(:admin) }

      before :each do
        request.headers['X-AuthToken'] = admin.api_token
        post 'create', :neighbourhood => { :name => 'Foo' }, :format => :json
      end

      it 'creates a new neighbourhood record' do
        expect(Neighbourhood.count).to eq(1)
      end

      it 'returns a neighbourhood object' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end
    end

    context 'invalid params' do
      before :each do
        post 'create', :neighbourhood => { :name => nil }, :format => :json
      end

      it 'does not create a new neighbourhood record' do
        expect(Neighbourhood.count).to eq(0)
      end

      it 'returns an validation error response' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
      end
    end
  end

  describe '#show' do
    let(:neighbourhood) { create(:neighbourhood) }

    context 'valid :id param' do
      it 'returns a neighbourhood object' do
        get 'show', :id => neighbourhood.id, :format => :json
        expect(response.status).to eq(200)
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end
    end

    context 'invalid :id param' do
      it 'returns a not found error response' do
        invalid_id = neighbourhood.id.to_i * rand(90)
        get 'show', :id => invalid_id, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
      end
    end
  end

  describe '#update' do
    let(:admin) { create(:admin) }
    let(:neighbourhood) { create(:neighbourhood) }
    let(:invalid_id)  { neighbourhood.id.to_i * rand(90) }

    context 'valid params' do
      it 'updates an existing neighbourhood record' do
        request.headers['X-AuthToken'] = admin.api_token
        put 'update', :id => neighbourhood.id, :neighbourhood => { :name => 'Foo' }, :format => :json
        expect(response.status).to eq(204)
        neighbourhood.reload
        expect(neighbourhood.name).to eq('Foo')
      end
    end

    context 'invalid params' do
      it 'return a not found error if neighbourhood does not exist' do
        put 'update', :id => invalid_id, :neighbourhood => { :name => 'Foo' }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        neighbourhood.reload
        expect(neighbourhood.name).to_not eq('Foo')
      end

      it 'returns a validation error if params fail validation' do
        put 'update', :id => neighbourhood.id, :neighbourhood => { :name => nil }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        neighbourhood.reload
        expect(neighbourhood.name).to_not eq('Foo')
      end
    end
  end

  describe '#destroy' do
    let(:admin) { create(:admin) }
    let(:neighbourhood) { create(:neighbourhood) }
    let(:invalid_id)  { neighbourhood.id.to_i * rand(90) }

    before :each do
      request.headers['X-AuthToken'] = admin.api_token
    end

    it 'deletes a neighbourhood record if exists' do
      delete 'destroy', :id => neighbourhood.id, :format => :json
      expect(Neighbourhood.count).to eq(0)
    end

    it 'returns a not found error if neighbourhood does not exist' do
      delete 'destroy', :id => invalid_id, :format => :json
      expect(Neighbourhood.count).to eq(1)
      mssg = parse_json(response.body)
      expect(mssg.keys).to include("error")
    end
  end
end