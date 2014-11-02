class API::V1::CategoriesController < BaseAPIController
  before_action :find_category, :only => [:show, :destroy, :update]
  load_and_authorize_resource :only => [:create, :update, :destroy, :index, :count]
  skip_load_resource :only => [:create, :index, :count]

  def index
    @categories = build_query.limit(query_limit).offset(query_offset)
    respond_with @categories, :root => false, :location => api_v1_categories_url
  end

  def count
    render :json => {:count => build_query.count }
  end

  def show
    respond_with @category, :location => api_v1_category_url(@category)
  end

  def destroy
    @category.destroy
    head :status => 204
  end

  def create
    @category = Category.new(:name => params[:name])
    return render :json => validation_error(@category, "A Category must have at least one Venue Type."),
      :status => 400 unless params[:add_venue_types]

    if @category.save
      update_venue_types
      respond_with @category, :location => api_v1_category_url(@category)
    else
      render :json => validation_error(@category), :status => 400
    end
  end

  def update
    if @category.update_attributes({:name => params[:name]})
      render :json => @category, :status => 200, :location => api_v1_category_url(@category)
    else
      render :json => validation_error(@category), :status => 400
    end
  end

  private

  def update_venue_types
    @category.venue_types = VenueType.find(params[:add_venue_types])
  end

  def find_category
    @category = Category.find(params[:id])
  end

  def build_query
    query = Category.all
    query = query.search(params[:search]) if params[:search]
    query
  end

end