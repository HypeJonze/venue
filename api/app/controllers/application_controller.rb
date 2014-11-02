class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  private

  # Builds a Google API Client with authorization based on the one time code in request_params...
  def get_gapi_client(request_params)
    if(request_params[:code].nil?)
      raise Tnr::AuthError.new("No ':code' parameter!")
    end

    client = Google::APIClient.new(
      application_name: "True North Records",
      application_version: "Dev")

    # add the auth_token
    client.authorization = gapi_authorization(request_params)
    return client
  end

  # authenticates and returns an auth token...
  def gapi_authorization(request_params)
    file_path = Rails.root.join('config', 'client_secrets.json')
    client_secrets = Google::APIClient::ClientSecrets.load(file_path)

    authorization = Signet::OAuth2::Client.new(
      authorization_uri: client_secrets.authorization_uri,
      token_credential_uri: client_secrets.token_credential_uri,
      client_id: client_secrets.client_id,
      client_secret: client_secrets.client_secret,
      scope: 'userInfo.profile, userInfo.email')

    if (!request_params[:code].nil?)
      authorization.redirect_uri = client_secrets.redirect_uris.first
      authorization.code = request_params[:code]
      authorization.fetch_access_token!
    end
    return authorization
  end

end
