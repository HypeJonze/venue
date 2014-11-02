class API::V1::NeighbourhoodsController < BaseAPIController
  before_action :find_neighbourhood, :only => [:show, :update, :destroy]
  load_and_authorize_resource :only => [:create, :update, :destroy, :index, :count]
  skip_load_resource :only => [:create, :index, :count]

  def index
    @neighbourhoods = build_query.limit(query_limit).offset(query_offset)
    respond_with @neighbourhoods, :root => false#, :location => api_v1_neighbourhoods_url
  end

  def count
    render :json => {:count => build_query.count }
  end

  def show
    respond_with @neighbourhood, :location => api_v1_neighbourhood_url(@neighbourhood)
  end

  def destroy
    @neighbourhood.destroy
    head :ok
  end

  def create
    @neighbourhood = Neighbourhood.new(neighbourhood_params)
    if @neighbourhood.save
      respond_with @neighbourhood, :location => api_v1_neighbourhood_url(@neighbourhood)
    else
      render :json => validation_error(@neighbourhood), :status => 400
    end
  end

  def update
    if @neighbourhood.update_attributes(neighbourhood_params)
      respond_with @neighbourhood, :location => api_v1_neighbourhood_url(@neighbourhood)
    else
      render :json => validation_error(@neighbourhood), :status => 400
    end
  end

  private

  def neighbourhood_params
    params.require(:neighbourhood).permit(:name)
  end

  def build_query
    query = Neighbourhood.all
    query = query.search(params[:search].to_s) if params[:search]
    query
  end

  def find_neighbourhood
    @neighbourhood = Neighbourhood.find(params[:id])
  end

end