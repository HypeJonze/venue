module ApiMessages
  # Base Error Messages
  def authentication_error
    {
      :error => 'Authentication Error.',
      :description => 'Email and Password combination is not valid.',
      :status => 400
    }.to_json
  end

  def oauth_email_not_verified_error(description)
    {
      :error => 'Authentication Error.',
      :description => description,
      :status => 400
    }.to_json
  end

  def forbidden_error
    {
      :error => 'Forbidden Request',
      :description => 'This operation is forbidden.',
      :status => 403
    }.to_json
  end

  def invalid_token_error
    {
      :error => 'Authentication Token Invalid.',
      :description => 'You must provide a valid authentication token in your request.',
      :status => 401
    }.to_json
  end

  def missing_token_error
    {
      :error => 'Authentication Token Missing.',
      :description => 'You must provide an authentication token in your request.',
      :status => 401
    }.to_json
  end

  def validation_error(object, message = nil)
    message ||= 'The action could not be completed due to validation errors.'
    {
      :error => 'Validation Error.',
      :description => message,
      :failed_validations => object.errors,
      :status => 400
    }.to_json
  end

  def validation_error_msg(object, message)
    {
      :error => 'Validation Error.',
      :description => message,
      :failed_validations => object.errors,
      :status => 400
    }.to_json
  end

  def not_found_error
    {
      :error => 'Not Found.',
      :description => 'The resource you are trying to access cannot be retrieved or does not exist.',
      :status => 404
    }.to_json
  end

  def signout_success
    {
      :success => 'Signout Confirmation.',
      :description => 'You have successfully signed out.',
      :status => 204
    }.to_json
  end
end