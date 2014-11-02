require 'spec_helper'

describe API::V1::CategoriesController do
  describe '#index' do
    before :each do
      create_list(:category, 50)
    end

    it 'returns a list of Categories' do
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
        @category = create(:category, :name => 'Workspace')
      end

      it 'filters to match Keywords that match a search string' do
        get 'index', :search => 'work', :format => :json
        assigns(:categories).should include(@category)
      end
    end
  end

  describe '#create' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:venue_type) { FactoryGirl.create(:venue_type) }

    context 'valid params' do
      before :each do
        request.headers['X-AuthToken'] = admin.api_token
        post 'create', :name => 'Foo', :add_venue_types => [venue_type.id], :format => :json
      end

      it 'must provide :add_venue_types in the params hash' do
        expect(response.status).to eq(201)
      end

      it 'creates a new Category record' do
        expect(Category.count).to eq(1)
      end

      it 'returns a Category object' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end

      it 'adds relationship to provided VenueType ids' do
        category = Category.last
        expect(category.venue_types).to include(venue_type)
      end
    end

    context 'invalid params' do
      before :each do
        request.headers['X-AuthToken'] = admin.api_token
        post 'create', :name => nil, :format => :json
      end

      it 'does not create a new Category record' do
        expect(Category.count).to eq(0)
      end

      it 'returns an validation error response' do
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        expect(mssg.values).to include('Validation Error.')
      end
    end
  end

  describe '#show' do
    let(:category) { create(:category) }

    context 'valid :id param' do
      it 'returns a category object' do
        get 'show', :id => category.id, :format => :json
        expect(response.status).to eq(200)
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("name")
      end
    end

    context 'invalid :id param' do
      it 'returns a not found error response' do
        invalid_id = category.id.to_i * rand(90)
        get 'show', :id => invalid_id, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
      end
    end
  end

  describe '#update' do
    let(:admin) { create(:admin) }
    let!(:category) { create(:category) }
    let!(:invalid_id)  { category.id.to_i * rand(90) }

    context 'valid params' do
      it 'updates an existing Category record' do
        request.headers['X-AuthToken'] = admin.api_token
        put 'update', :id => category.id, :name => 'Foo', :format => :json
        expect(response.status).to eq(200)
        category.reload
        expect(category.name).to eq('Foo')
      end
    end

    context 'invalid params' do
      it 'return a not found error if Category does not exist' do
        put 'update', :id => invalid_id, :category => { :name => 'Foo' }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        category.reload
        expect(category.name).to_not eq('Foo')
      end

      it 'returns a validation error if params fail validation' do
        put 'update', :id => category.id, :category => { :name => nil }, :format => :json
        mssg = parse_json(response.body)
        expect(mssg.keys).to include("error")
        category.reload
        expect(category.name).to_not eq('Foo')
      end
    end
  end

  describe '#destroy' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:category) { create(:category) }
    let(:invalid_id)  { category.id.to_i * rand(90) }

    it 'deletes a Category record if exists' do
      request.headers['X-AuthToken'] = admin.api_token
      delete 'destroy', :id => category.id, :format => :json
      expect(Category.count).to eq(0)
    end

    it 'returns a not found error if Category does not exist' do
      delete 'destroy', :id => invalid_id, :format => :json
      expect(Category.count).to eq(1)
      mssg = parse_json(response.body)
      expect(mssg.keys).to include("error")
      expect(mssg.values).to include('Not Found.')
    end
  end
end