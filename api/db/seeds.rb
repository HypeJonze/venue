require 'csv'
require 'cgi'
require 'curb'

$raise_on_invalid_data = false

# Validates that a Keyword belongs to at least one of the Venue Type's Cateogories.
def validate_keyword_against_venue_types(keyword, venue_types)
  venue_types.each do |venue_type|
    return true unless !venue_type.categories.include?(keyword.category)
  end
  false
end

def test_image_url(url)
  c = Curl::Easy.http_head(url) {|easy| easy.follow_location = true}
  c.perform
  puts "url: #{url} returned status #{c.response_code}" unless c.response_code == 200
end

def raise_or_puts(msg)
  unless $raise_on_invalid_data then
    puts msg
  else
    raise msg
  end
end

s3_base_path = "http://s3-us-west-2.amazonaws.com/venuetorontoseedimages/logos_and_artwork_aspects/"
venue_types = {}
categories = {}
keywords = {}
neighbourhoods = {}
venues = {}

puts "Seeding Neighbourhoods..."
CSV.foreach("#{File.dirname(__FILE__)}/neighbourhood_seeds.csv", {:headers => :first_row, :header_converters => :symbol}) do |row|
  row[:id].strip!
  row[:name].strip!
  neighbourhoods[row[:id]] = Neighbourhood.create(row.to_hash.extract!(:name))
end
puts "Seeding Neighbourhoods Done!"

puts "Seeding Venue Types..."
CSV.foreach("#{File.dirname(__FILE__)}/venue_type_seeds.csv", {:headers => :first_row, :header_converters => :symbol}) do |row|
  row[:id].strip!
  row[:name].strip!
  venue_types[row[:id]] = VenueType.create(row.to_hash.extract!(:name))
end
puts "Seeding Venue Types Done!"

puts "Seeding Categories..."
CSV.foreach("#{File.dirname(__FILE__)}/category_seeds.csv", {:headers => :first_row, :header_converters => :symbol}) do |row|
  row[:id].strip!
  row[:name].strip!
  attributes = row.to_hash.extract!(:name)
  attributes[:venue_types] = []
  row[:venue_type_ids].split(',').each do |venue_type_id|

    #trim whitespace
    venue_type_id.strip!

    #takes care of empty strings as a result of trailing commas
    next unless !venue_type_id.empty?
    
    unless !venue_types.has_key?(venue_type_id) then
      attributes[:venue_types] << venue_types[venue_type_id]
    else
      # Venue Type by this ID is not found
      raise_or_puts "Unrecognised Venue Type by ID '#{venue_type_id}'."
    end
  end
  categories[row[:id]] = Category.create(attributes)
end
puts "Seeding Categories Done!"

puts "Seeding Keywords..."
CSV.foreach("#{File.dirname(__FILE__)}/keyword_seeds.csv", {:headers => :first_row, :header_converters => :symbol}) do |row|
  row[:id].strip!
  row[:category_id].strip!
  attributes = row.to_hash.extract!(:name)
  attributes[:venue_types] = []

  category = categories[row[:category_id]]
  unless category.nil? then
    attributes[:category] = category
  else
    raise_or_puts "Unrecognised Category by ID '#{row[:category_id]}'."
  end

  # parse venue type ids
  row[:venue_type_ids].split(',').each do |venue_type_id|
    #trim whitespace
    venue_type_id.strip!

      #takes care of empty strings as a result of trailing commas
    next unless !venue_type_id.empty?
    
    if !venue_types.has_key?(venue_type_id)
      # Venue Type by this ID is not found
      raise_or_puts "Unrecognised Venue Type by ID '#{venue_type_id}'."
    elsif !venue_types[venue_type_id].categories.include?(category)
      #Venue Type is not also a member of Keyword's nominated Category
      raise_or_puts "Venue Type '#{venue_types[venue_type_id]}' is not attributed to Category '#{category.name}'."
    else
      attributes[:venue_types] << venue_types[venue_type_id]
    end
  end
  keywords[row[:id]] = Keyword.create(attributes)

end
puts "Seeding Keywords Done!"

venue_attributes = [:name, :description, :address, :address_secondary, :intersection, :city, :state, :country, :zip, :food, :music, :style, :crowd, :specialty, :specials, :price_range, :dress_code, :entry_fee, :hours, :date, :parking, :contact_phone];

puts "Seeding Venues..."
CSV.foreach("#{File.dirname(__FILE__)}/venue_seeds.csv", {:headers => :first_row, :header_converters => :symbol}) do |row|
  attributes = row.to_hash.extract!(*venue_attributes)
  attributes[:venue_types] = []
  row[:venue_type_ids].split(',').each do |venue_type_id|
    venue_type_id.strip!

    #takes care of empty strings as a result of trailing commas
    next unless !venue_type_id.empty?
    
    unless !venue_types.has_key?(venue_type_id) then
      attributes[:venue_types] << venue_types[venue_type_id]
    else
      # Venue Type by this ID is not found
      raise_or_puts "Unrecognised Venue Type by ID '#{venue_type_id}'."
    end
  end

  attributes[:keywords] = []
  attributes[:photos] = []
  logo_url = "#{s3_base_path}#{CGI.escape(row[:logo])}"
  logo_url.gsub! '%2F', '/'
  puts "Attaching logo with remote url: #{logo_url}"
  attributes[:remote_logo_url] = logo_url
  # test_image_url(logo_url)
  
  row[:photos] ||= ""
  row[:photos].split(',').each do |photo_path|
    photo_path.strip!
    next unless !photo_path.empty?
    photo_url = "#{s3_base_path}#{CGI.escape(photo_path)}"
    photo_url.gsub! '%2F', '/'
    puts "Attaching photo with remote url: #{photo_url}"
    photo = Photo.create!({ remote_image_url: photo_url })
    photo.save!
    attributes[:photos] << photo
    # test_image_url(photo_url)
  end

  row[:keyword_ids].split(',').each do |keyword_id|
    keyword_id.strip!

    #takes care of empty strings as a result of trailing commas
    next unless !keyword_id.empty?

    if !keywords.has_key?(keyword_id)
      # Venue Type by this ID is not found
      raise_or_puts "Unrecognised Keyword by ID '#{keyword_id}'."
    elsif !validate_keyword_against_venue_types(keywords[keyword_id], attributes[:venue_types])
      raise_or_puts "Keyword by ID '#{keyword_id}' is not applicable to this Venue's Venue Types. Venue: #{row[:name]}"      
    else
      attributes[:keywords] << keywords[keyword_id]  
    end
  end

  if !row[:neighbourhood_id].nil? and !row[:neighbourhood_id].empty? and neighbourhoods.has_key?(row[:neighbourhood_id]) then
    attributes[:neighbourhood] = neighbourhoods[row[:neighbourhood_id]]
  elsif !row[:neighbourhood_id].nil? and !row[:neighbourhood_id].empty?
    raise_or_puts "Invalid Neighbourhood ID '#{row[:neighbourhood_id]}'."
  end


  venue = Venue.create!(attributes)
  venue.save!
end
puts "Seeding Venues Done!"