class API::V1::VenueTypesController < BaseAPIController
  before_action :find_venue_type, :only => [:show, :update, :destroy]
  load_and_authorize_resource :only => [:create, :update, :destroy, :index, :count]
  skip_load_resource :only => [:create, :index, :count]

  def index
    @venue_types = build_query.limit(query_limit).offset(query_offset)
    respond_with @venue_types, :root => false, :location => api_v1_venue_types_url
  end

  def count
    render :json => {:count => build_query.count }
  end

  def show
    respond_with @venue_type, :location => api_v1_venue_type_url(@venue_type)
  end

  def destroy
    @venue_type.destroy
    head :ok
  end

  def create
    @venue_type = VenueType.new(venue_type_params)
    if @venue_type.save
      respond_with @venue_type, :location => api_v1_venue_type_url(@venue_type)
    else
      render :json => validation_error(@venue_type), :status => 400
    end
  end

  def update
    if @venue_type.update_attributes(venue_type_params)
      respond_with @venue_type, :location => api_v1_venue_type_url(@venue_type)
    else
      render :json => validation_error(@venue_type), :status => 400
    end
  end

  private

  def venue_type_params
    params.require(:venue_type).permit(:name)
  end

  def build_query
    query = VenueType.includes(:categories, :keywords)
    query = query.search(params[:search]) if params[:search]
    query
  end

  def find_venue_type
    @venue_type = VenueType.find(params[:id])
  end
end