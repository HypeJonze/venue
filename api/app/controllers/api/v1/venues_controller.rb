require 'stringio'

class API::V1::VenuesController < BaseAPIController
  before_action :index_query, :only => [:index, :count]
  before_action :find_venue, :only => [:show, :update, :destroy]
  load_and_authorize_resource :only => [:create, :update, :destroy, :index, :count]
  skip_load_resource :only => [:create, :index, :count]

  def index
    @venues = @query.limit(query_limit).offset(query_offset)
    respond_with @venues, :root => false, :location => api_v1_venues_url
  end

  def count
    render :json => {:count => @query.count }
  end

  def show
    respond_with @venue, :location => api_v1_venue_url(@venue)
  end

  def destroy
    @venue.destroy
    head :ok
  end

  def create
    @venue = Venue.new(current_user.role == 'admin' ? venue_params_admin : venue_params_user)

    # force user_id field to the current user's id unless the user is admin
    @venue.user_id = current_user.id unless current_user.role == 'admin'
    if current_user.role == 'admin' 
      admin_save
    else
      user_save
    end
    if @venue.save
      respond_with @venue, :location => api_v1_venue_url(@venue)
    else
      render :json => validation_error(@venue), :status => 400
    end
  end

  def update
    begin
      if current_user.role == 'admin' 
        admin_update
      else
        user_update
      end
      respond_with @venue, :location => api_v1_venue_url(@venue)
    rescue ActiveRecord::RecordNotSaved => e
      render :json => validation_error(@venue), :status => 400
    end
  end

  private

  def admin_save
    update_venue_types
    update_keywords
    update_photos
    update_logo
    @venue.update_attributes!(venue_params_admin)
  end

  def user_save
    update_photos
    update_logo
    @venue.update_attributes!(venue_params_user)
  end

  def admin_update
    update_owner # TODO!
    update_venue_types
    update_keywords
    update_photos
    update_logo
    @venue.update_attributes!(venue_params_admin)
  end

  def user_update
    update_photos
    update_logo
    @venue.update_attributes!(venue_params_user)
  end

  def update_owner

  end

  def update_venue_types
    changes = 0
    if params[:add_venue_types].present?
      changes += params[:add_venue_types].length
      venue_types_to_add = VenueType.find(params[:add_venue_types])
      venue_types_to_add.each do |venue_type|
        @venue.venue_types << venue_type
      end
    end
    if params[:remove_venue_types].present?
      changes += params[:remove_venue_types].length
      venue_types_to_remove = VenueType.find(params[:remove_venue_types])
      venue_types_to_remove.each do |venue_type|
        @venue.venue_types.delete(venue_type)
      end
    end

    if changes > 0
      # check for and remove invalid keywords
      @venue.keywords.each do |keyword|
        got_category_match = false
        @venue.venue_types.each do |venue_type|
          if venue_type.categories.include?(keyword.category)
            got_category_match = true
            break
          end
        end
        @venue.keywords.delete(keyword) unless got_category_match
      end
    end
  end

  def update_keywords
    if params[:add_keywords].present?
      keywords_to_add = Keyword.find(params[:add_keywords])
      keywords_to_add.each do |keyword|
        matched = false
        @venue.venue_types.each do |venue_type|
          venue_type.categories.each do |category|
            if keyword.category_id == category.id
              matched = true
              @venue.keywords << keyword
            end
            break if matched
          end
          break if matched
        end
      end
    end
    if params[:remove_keywords].present?
      keywords_to_remove = Keyword.find(params[:remove_keywords])
      keywords_to_remove.each do |keyword|
        @venue.keywords.delete(keyword)
      end
    end
  end

  def update_photos
    if params[:add_photos].present?
      params[:add_photos].each do |photo_data|
        photo = Photo.create!({:image => process_base64_logo(photo_data[:content], photo_data[:file_name], photo_data[:file_type])})
        photo.save!
        @venue.photos << photo
      end
    end
    if params[:remove_photos].present?
      photos_to_remove = Photo.find(params[:remove_photos])
      photos_to_remove.each do |photo|
        @venue.photos.delete(photo)
      end
    end
  end

  def update_logo
    if params[:logo_data].present?
      if params[:logo_data].nil?
        @venue.logo = nil
      elsif params[:logo_file_name].present? and !params[:logo_file_name].empty? and params[:logo_file_type].present? and !params[:logo_file_type].empty?
        @venue.logo = process_base64_logo(params[:logo_data], params[:logo_file_name], params[:logo_file_type])
      else
        render :json => validation_error_msg(@venue, "The logo was missing the :logo_file_type or :logo_file_name param."), :status => 400
      end
    end
  end

  def process_base64_logo content, file_name, file_type
    img_data_sio = nil
    if content.match(%r{^data:(.*?);(.*?),(.*)$})
      img_data = {
        :type =>      $1, # "image/png"
        :encoder =>   $2, # "base64"
        :data_str =>  $3, # data string
        :extension => $1.split('/')[1] # "png"
      }

      img_data_sio = FilelessIO.new(Base64.decode64(img_data[:data_str]))
      img_data_sio.original_filename = file_name
      img_data_sio.content_type = file_type
    end
    img_data_sio
  end

  def venue_params_admin
    params.require(:venue).permit(
      :name, :neighbourhood_id, :description, :address, :address_secondary,
      :intersection, :city, :state, :country, :zip, :contact_email, :contact_phone,
      :food, :music, :dress_code, :entry_fee, :style, :crowd, :specialty,
      :specials, :price_range, :parking, :hours, :date,
      :enabled, :featured
    )
  end

  def venue_params_user
    params.require(:venue).permit(
      :name, :neighbourhood_id, :description, :address, :address_secondary,
      :intersection, :city, :state, :country, :zip, :contact_email, :contact_phone,
      :food, :music, :dress_code, :entry_fee, :style, :crowd, :specialty,
      :specials, :price_range, :parking, :hours, :date
    )
  end

  def index_query
    @query = Venue.includes(
      {
        :keywords => [:category, { :venue_types => :categories }]
      }, :photos, :neighbourhood, { :venue_types => :categories }
    ).distinct.joins("LEFT JOIN venue_types_venues ON venue_types_venues.venue_id = venues.id", 
      "LEFT JOIN venue_types ON venue_types.id = venue_types_venues.venue_type_id")
    @query = @query.for_user(current_user.id) if current_user and current_user.role == 'user'
    @query = @query.in_neighbourhood(params[:neighbourhood_id]) if params[:neighbourhood_id]
    @query = @query.of_venue_type(params[:venue_type_id]) if params[:venue_type_id]
    @query = @query.match_name(params[:search_name]) if params[:search_name]
    @query = @query.featured if params[:featured]
    if params[:sort_keywords]
      ids = params[:sort_keywords].split(',')
      @query = @query.with_at_least_one_keyword(ids)
    else
      @query = @query.order(:id)
    end

    @query
  end

  def find_venue
    @venue = Venue.includes(
      {:keywords => [:category, :venue_types]}, :photos, {:venue_types => [:categories]}, :neighbourhood
    ).find(params[:id])
  end

end