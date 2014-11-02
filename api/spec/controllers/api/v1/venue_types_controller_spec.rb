require 'spec_helper'

describe API::V1::VenueTypesController do
  describe '#index' do
    before do
      create_list(:venue_type, 50)
    end

    it 'returns a list of venue_types' do
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
        @venue_type = create(:venue_type, :name => 'Workspace')
      end

      it 'filters to match VenueTypes that match a search string' do
        get 'index', :search => 'work', :format => :json
        assigns(:venue_types).should include(@venue_type)
      end
    end
  end

  describe '#create' do
    let(:admin) { create(:admin) }

    context 'valid params' do
      before :each do
        request.headers['X-AuthToken'] = admin.api_token
        post 'create', :venue_type => { :name => 'Foo' }, :format => :json
      end

      it 'creates a new venue_type record' do
        expect(VenueType.count).to eq(1)
      end

      it 'returns a venue_type object' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end
    end

    context 'invalid params' do
      before :each do
        request.headers['X-AuthToken'] = admin.api_token
        post 'create', :venue_type => { :name => nil }, :format => :json
      end

      it 'does not create a new venue_type record' do
        expect(VenueType.count).to eq(0)
      end

      it 'returns an validation error response' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
      end
    end
  end

  describe '#show' do
    let(:venue_type) { create(:venue_type) }

    context 'valid :id param' do
      it 'returns a venue_type object' do
        get 'show', :id => venue_type.id, :format => :json
        expect(response.status).to eq(200)
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end
    end

    context 'invalid :id param' do
      it 'returns a not found error response' do
        invalid_id = venue_type.id.to_i * rand(90)
        get 'show', :id => invalid_id, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
      end
    end
  end

  describe '#update' do
    let(:admin) { create(:admin) }
    let(:venue_type) { create(:venue_type) }
    let(:invalid_id)  { venue_type.id.to_i * rand(90) }

    before :each do
      request.headers['X-Authtoken'] = admin.api_token
    end

    context 'valid params' do
      it 'updates an existing venue_type record' do
        put 'update', :id => venue_type.id, :venue_type => { :name => 'Foo' }, :format => :json
        expect(response.status).to eq(204)
        venue_type.reload
        expect(venue_type.name).to eq('Foo')
      end
    end

    context 'invalid params' do
      it 'return a not found error if venue_type does not exist' do
        put 'update', :id => invalid_id, :venue_type => { :name => 'Foo' }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        venue_type.reload
        expect(venue_type.name).to_not eq('Foo')
      end

      it 'returns a validation error if params fail validation' do
        put 'update', :id => venue_type.id, :venue_type => { :name => nil }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        venue_type.reload
        expect(venue_type.name).to_not eq('Foo')
      end
    end
  end

  describe '#destroy' do
    let(:admin) { create(:admin) }
    let(:venue_type) { create(:venue_type) }
    let(:invalid_id)  { venue_type.id.to_i * rand(90) }

    before :each do
      request.headers['X-AuthToken'] = admin.api_token
    end

    it 'deletes a venue_type record if exists' do
      delete 'destroy', :id => venue_type.id, :format => :json
      expect(VenueType.count).to eq(0)
    end

    it 'returns a not found error if venue_type does not exist' do
      delete 'destroy', :id => invalid_id, :format => :json
      expect(VenueType.count).to eq(1)
      mssg = parse_json(response.body)
      expect(mssg.keys).to include("error")
      expect(mssg.values).to include("Not Found.")
    end
  end
end