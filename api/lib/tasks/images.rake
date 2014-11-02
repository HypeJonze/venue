namespace :images do
  desc "Regenerate Versions of Logo Images"
  task regenerate_logo_versions: :environment do
    Venue.all.each do |venue| 
      begin
        venue.logo.cache_stored_file!
        venue.logo.retrieve_from_cache!(venue.logo.cache_name) 
        venue.logo.recreate_versions!
        venue.save!
      rescue => e
        puts  "ERROR: Venue: #{venue.id} -> #{e.to_s}"
      end
    end    
  end

end
