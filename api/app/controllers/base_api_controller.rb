class BaseAPIController < ApplicationController
  include ApiMessages

  respond_to :json
  prepend_before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    render :json => forbidden_error, :status => 403
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render :json => not_found_error, :status => 404
  end


  def query_limit
    default_limit = 25
    begin
      limit = Integer(params[:limit])
      limit = limit.nil? || !limit.between?(1, 200) ? default_limit : limit
    rescue ArgumentError, TypeError
      limit = default_limit
    end
  end

  def query_offset
    begin
      offset = Integer(params[:offset])
      offset = offset.nil? ? 0 : [offset, 0].max
    rescue ArgumentError, TypeError
      offset = 0
    end
  end

  def authenticate_user!
    return @current_user = User.new if request.headers['X-AuthToken'].nil?

    @current_user = User.find_by(:api_token => request.headers['X-AuthToken'])
    render :json => invalid_token_error, :status => 401 unless @current_user
  end

  def current_user
    @current_user
  end
end