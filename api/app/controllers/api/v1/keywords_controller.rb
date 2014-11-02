class API::V1::KeywordsController < BaseAPIController
  before_action :find_keyword, :only => [:update, :destroy, :show]
  load_and_authorize_resource :only => [:create, :update, :destroy, :index, :count]
  skip_load_resource :only => [:create, :index, :count]

  def index
    @keywords = build_query.limit(query_limit).offset(query_offset)
    respond_with @keywords, :root => false, :location => api_v1_keywords_url
  end

  def count
    render :json => {:count => build_query.count }
  end

  def show
    respond_with @keyword, :location => api_v1_keyword_url(@keyword)
  end

  def destroy
    @keyword.destroy
    head :ok
  end

  def create
    @keyword = Keyword.new(params.require(:keyword).permit(:name, :category_id))

    if @keyword.save
      update_venue_types if params[:add_venue_types]
      respond_with @keyword, :status => 204, :location => api_v1_keyword_url(@keyword)
    else
      render :json => validation_error(@keyword), :status => 400
    end
  end

  def update
    if @keyword.update_attributes(params.require(:keyword).permit(:name))
      respond_with @keyword, :status => 200, :location => api_v1_keyword_url(@keyword)
    else
      render :json => validation_error(@keyword), :status => 400
    end
  end

  private

  def update_venue_types
    @keyword.venue_types = VenueType.find(params[:add_venue_types])
  end

  def build_query
    query = Keyword.includes(:venue_types, :category).order(:id)
    query = query.search(params[:search]) if params[:search]
    query
  end

  def find_keyword
    @keyword = Keyword.find(params[:id])
  end

end