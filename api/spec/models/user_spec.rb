require 'spec_helper'

describe User do
  it { should validate_presence_of :email }

  describe 'an instance' do
    it 'assigns a random password if not provided' do
      user = create(:user, :password => nil, :password_confirmation => nil)
      expect(user.password_digest).to_not be_nil
    end

    it 'respects password if provided' do
      user = create(:user, :password => 'password', :password_confirmation => 'password')
      expect(user.authenticate('password')).to eq(user)
    end
  end

  describe '#email' do
    it 'is unique' do
      create(:user, :email => 'john@example.com')
      user = build(:user, :email => 'john@example.com')

      expect(user).to_not be_valid
      expect(user.errors.messages).to include(:email => ["has already been taken"])
    end

    it 'is a valid format' do
      user = build(:user, :email => 'user @ invalid . com')
      expect(user).to_not be_valid
      expect(user.errors.messages).to include(:email => ["format is invalid"])
    end
  end


  describe '#api_token' do
    it 'calls SecureRandom.base64' do
      SecureRandom.should_receive(:base64)
      create(:user)
    end

    it 'gets generated upon creation' do
      user = create(:user)
      expect(user.api_token).to_not be_nil
    end

    it 'is unique' do
      john = create(:user, :email => 'johndoe@example.com')
      jane = create(:user, :email => 'janedoe@example.com')
      expect(jane.api_token).to_not eq(john.api_token)
    end
  end

  describe '#password_digest' do
    it 'is generated upon creation' do
      user = create(:user)
      expect(user.password_digest).to_not be_nil
    end
  end

  describe '.authenticate_from_hash' do
    let(:google_hash) { 
      double('Google::APIClient::Schema::Oauth2::V2::Userinfoplus',
        :verified_email => true, :email => 'john@gmail.com',
        :family_name => 'Doe', :given_name => 'John',
        :picture => 'https://lh5.googleusercontent.com/-Q2Wz058FlOk/AAAAAAAAAAI/AAAAAAAAB-A/_XgI3TBcv-s/photo.jpg'
      )
    }

    context 'user exists in database' do
      let!(:user) { create(:user, :email => 'john@gmail.com') }

      it 'returns user record from db' do
        expect(User.authenticate_from_hash(google_hash)).to eq(user)
      end
    end

    context 'user does not exist in database' do
      let(:user) { User.authenticate_from_hash(google_hash) }

      it 'returns a newly created User' do
        expect(user).to be_a(User)
      end

      it 'user returned is not an admin' do
        expect(user.role).to_not eq('admin')
      end
    end
  end
end
