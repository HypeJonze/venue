require 'spec_helper'

describe API::V1::KeywordsController do
  describe '#index' do
    let(:category) { create(:category) }
    before do
      50.times { create(:keyword, :category => category) }
    end

    it 'returns a list of keywords' do
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
        @keyword = create(:keyword, :name => 'Workspace')
      end

      it 'filters to match Keywords that match a search string' do
        get 'index', :search => 'work', :format => :json
        assigns(:keywords).should include(@keyword)
      end
    end
  end

  describe '#create' do
    context 'valid params' do
      let(:admin) { create(:admin) }
      let(:venue_type) { create(:venue_type) }
      let(:category) { create(:category) }

      before :each do
        request.headers['X-AuthToken'] = admin.api_token
        post 'create', :keyword => { :name => 'Foo', :category_id => category.id },
          :format => :json
      end

      it 'creates a new keyword record' do
        expect(Keyword.count).to eq(1)
      end

      it 'returns a keyword object' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end

      context 'includes VenueType ids' do
        before :each do
          request.headers['X-AuthToken'] = admin.api_token
          post 'create', :keyword => { :name => 'Bar', :category_id => category.id },
            :add_venue_types => [venue_type.id], :format => :json
        end

        it 'can receive :add_venue_types in params hash' do
          expect(response.status).to eq(204)
        end

        it 'adds relationship to VenueType :ids provided' do
          keyword = Keyword.last
          expect(keyword.venue_types).to include(venue_type)
        end
      end

    end

    context 'invalid params' do
      before :each do
        post 'create', :keyword => { :name => nil }, :format => :json
      end

      it 'does not create a new keyword record' do
        expect(Keyword.count).to eq(0)
      end

      it 'returns an validation error response' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
      end
    end
  end

  describe '#show' do
    let(:keyword) { create(:keyword) }

    context 'valid :id param' do
      it 'returns a keyword object' do
        get 'show', :id => keyword.id, :format => :json
        expect(response.status).to eq(200)
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end
    end

    context 'invalid :id param' do
      it 'returns a not found error response' do
        invalid_id = keyword.id.to_i * rand(90)
        get 'show', :id => invalid_id, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
      end
    end
  end

  describe '#update' do
    let(:admin) { create(:admin) }
    let(:keyword) { create(:keyword) }
    let(:invalid_id)  { keyword.id.to_i * rand(90) }

    context 'valid params' do
      it 'updates an existing keyword record' do
        request.headers['X-AuthToken'] = admin.api_token
        put 'update', :id => keyword.id, :keyword => { :name => 'Foo' }, :format => :json
        expect(response.status).to eq(204)
        keyword.reload
        expect(keyword.name).to eq('Foo')
      end
    end

    context 'invalid params' do
      it 'return a not found error if keyword does not exist' do
        put 'update', :id => invalid_id, :keyword => { :name => 'Foo' }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        keyword.reload
        expect(keyword.name).to_not eq('Foo')
      end

      it 'returns a validation error if params fail validation' do
        put 'update', :id => keyword.id, :keyword => { :name => nil }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        keyword.reload
        expect(keyword.name).to_not eq('Foo')
      end
    end
  end

  describe '#destroy' do
    let(:admin) { create(:admin) }
    let(:keyword) { create(:keyword) }
    let(:invalid_id)  { keyword.id.to_i * rand(90) }

    it 'deletes a keyword record if exists' do
      request.headers['X-AuthToken'] = admin.api_token
      delete 'destroy', :id => keyword.id, :format => :json
      expect(Keyword.count).to eq(0)
    end

    it 'returns a not found error if keyword does not exist' do
      request.headers['X-AuthToken'] = admin.api_token
      delete 'destroy', :id => invalid_id, :format => :json
      expect(Keyword.count).to eq(1)
      mssg = parse_json(response.body)
      expect(mssg.keys).to include("error")
      expect(mssg.values).to include('Not Found.')
    end
  end
end