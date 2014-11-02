require 'csv'
require 'curb'
require 'cgi'

def test_image_url(url)
  c = Curl::Easy.http_head(url) {|easy| easy.follow_location = true}
  c.perform
  # puts "!!!!!!!!!!!!!!" unless c.response_code == 200
  puts "url: #{url} returned status #{c.response_code}" unless c.response_code == 200
  # puts "!!!!!!!!!!!!!!" unless c.response_code == 200
end

s3_base_path = "http://s3-us-west-2.amazonaws.com/venuetorontoseedimages/logos_and_artwork_aspects/"

CSV.foreach("#{File.dirname(__FILE__)}/venue_seeds.csv", {:headers => :first_row, :header_converters => :symbol}) do |row|
  puts "Testing Venue by id: #{row[:name]}"

  row[:logo].strip!
  logo_url = "#{s3_base_path}#{CGI.escape(row[:logo])}"
  test_image_url(logo_url)
  row[:photos] ||= ""
  row[:photos].split(',').each do |photo_path|
    photo_path.strip!
    next unless !photo_path.empty?
    photo_url = "#{s3_base_path}#{CGI.escape(photo_path)}"
    test_image_url(photo_url)
  end
end