require 'spec_helper'

describe API::V1::AuthController do
  let(:valid_user) { 
    double('Google::APIClient::Schema::Oauth2::V2::Userinfoplus',
      :verified_email => true, :email => 'john@gmail.com',
      :family_name => 'Doe', :given_name => 'John',
      :picture => 'https://lh5.googleusercontent.com/-Q2Wz058FlOk/AAAAAAAAAAI/AAAAAAAAB-A/_XgI3TBcv-s/photo.jpg'
    )
  }
  let(:invalid_user) { 
    double('Google::APIClient::Schema::Oauth2::V2::Userinfoplus',
      :verified_email => false, :email => 'john@gmail.com',
      :family_name => 'Doe', :given_name => 'John',
      :picture => 'https://lh5.googleusercontent.com/-Q2Wz058FlOk/AAAAAAAAAAI/AAAAAAAAB-A/_XgI3TBcv-s/photo.jpg'
    )
  }

  describe '#google_oauth2_callback' do
    params = {
      :state=>"",
      :code=>"4/lVrnMnK-QU2N54hP6s_8biio7hfa.shP7Othy9S8REnp6UAPFm0H2UOHEiwI",
      :scope=>
      "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile",
      :client_id=>
      "616286677689-t3pclbc11spvvv34o3uas432801qf8s9.apps.googleusercontent.com",
      :g_user_cookie_policy=>"http://test.example.com:3000",
      :cookie_policy=>"http://test.example.com:3000",
      :response_type=>"code",
      :issued_at=>"1399663285",
      :expires_in=>"86400",
      :expires_at=>"1399749685",
      :"g-oauth-window"=>"",
      :status=>{"google_logged_in"=>"false", "signed_in"=>"false", "method"=>""}
    }

    it 'renders a JSON representation of a User retrieved/created if validated by Google'

    context 'email not validated' do
      before do
      end

      it 'renders an error JSON if not validated by Google' do
        @controller.stub(:params) { params }
        @controller.stub(:oauth2_hash) { double('Google::APIClient::Response', :userinfo => 'foo') }
        FakeWeb.register_uri(:post, "https://accounts.google.com/o/oauth2/token", :body => "{\"iss\":\"accounts.google.com\",
 \"at_hash\":\"HK6E_P6Dh8Y93mRNtsDB1Q\",\"email_verified\":\"true\",\"sub\":\"10769150350006150715113082367\",
 \"azp\":\"1234987819200.apps.googleusercontent.com\",
 \"email\":\"jsmith@example.com\",\"aud\":\"1234987819200.apps.googleusercontent.com\",
 \"iat\":1353601026,\"exp\":1353604926}")
        FakeWeb.register_uri(:get, "https://www.googleapis.com/discovery/v1/apis/oauth2/v2/rest", :body => "{\"foo\":\"bar\"}")
      end
    end
  end
end