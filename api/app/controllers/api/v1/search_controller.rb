class API::V1::SearchController < BaseAPIController
  before_action :validate_request, :only => [:results]
  before_action :find_venue_type, :only => [:results]
  before_action :total, :only => [:results]

  def results
    @results = @total.limit(query_limit).offset(query_offset)
    respond_with @results, :each_serializer => VenueListSerializer
  end

  def metadata
    @venue_types = VenueType.includes(:categories, { :keywords => [:venue_types, :category] }).load
    respond_with @venue_types, :each_serializer => VenueTypeMetadataSerializer,
      :root => 'venue_types'
  end

  private
  def validate_request
    render :json => missing_keys_error, :status => 400 unless params[:neighbourhood_id] && params[:venue_type_id]
  end

  def missing_keys_error
    {
      :error => 'Missing Keys.',
      :description => 'You must provide both a :neighbourhood_id and :venue_type_id params.',
      :status => 400
    }.to_json
  end

  def total
    @total = @venue_type.venues.includes(:neighbourhood, :keywords => :category).joins(:neighbourhood).where(
      :neighbourhood_id => params[:neighbourhood_id]
    )
  end

  def find_venue_type
    @venue_type = VenueType.find(params[:venue_type_id])
  end
end