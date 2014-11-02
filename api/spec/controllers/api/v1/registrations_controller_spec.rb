require 'spec_helper'

describe API::V1::RegistrationsController do
  describe 'create' do
    it 'creates a new User with valid params' do
      post 'create', :user => { 
        :email => 'john@example.com', :password => 'password', :password_confirmation => 'password'
      }, :format => :json
      expect(User.count).to eq(1)
      expect(response.status).to eq(201)
    end

    it 'returns an error when invalid params' do
      post 'create', :user => { :email => 'james@example' }, :format => :json
      expect(User.count).to eq(0)

      mssg = parse_json(response.body)
      expect(mssg.keys).to include("error")
      expect(response.status).to eq(400)
    end
  end

  describe '#destroy' do
    let(:admin) { create(:admin) }
    let(:user) { create(:user, :email => 'john@example.com') }

    it 'requires an admin token' do
      delete 'destroy', :id => user.id, :format => :json
      expect(User.count).to eq(1)
      mssg = parse_json(response.body)
      expect(mssg.keys).to include("error")
      expect(response.status).to eq(403)
    end

    it 'destroy a User record if exists' do
      request.headers['X-AuthToken'] = admin.api_token
      delete 'destroy', :id => user.id, :format => :json
      expect(User.all).to_not include(user)
      expect(response.status).to eq(204)
    end
  end
end
