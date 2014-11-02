if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
else # production
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_credentials = {
      :provider => 'AWS',
      :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
      :path_style => true
    }
    config.fog_directory = Rails.env.development? ? ENV['FOG_SANDBOX_DIRECTORY'] : ENV['FOG_DIRECTORY']
    config.fog_public = true
    config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
  end
end