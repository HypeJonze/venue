require 'google/api_client'
require 'google/api_client/client_secrets'

class API::V1::AuthController < BaseAPIController
  before_action :google_client, :only => [:google_oauth2_callback]
  before_action :oauth2_hash, :only => [:google_oauth2_callback]
  before_action :user_info, :only => [:google_oauth2_callback]

  def google_oauth2_callback
    return render :json => oauth_email_not_verified_error(
        "Your email is not yet verified with Google."
      ), :status => 400 unless user_info.data.verified_email

    @user = User.authenticate_from_hash(user_info.data)
    respond_with @user, :location => ""
  end

  private
  def google_client
    @client ||= get_gapi_client(params) 
  end

  def oauth2_hash
    @oauth2 ||= @client.discovered_api('oauth2', 'v2')
  end

  def get_user_info
    google_client.execute!(
      :api_method => oauth2_hash.userinfo.get,
      :parameters => {'userId' => 'me'}
    )
  end

  def user_info
    @user_info ||= get_user_info
  end
end
