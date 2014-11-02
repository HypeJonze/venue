# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    "uploads/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :resize_to_fit => [800, 800]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :landscape_large do
    process :resize_to_fill => [800, 400]
  end

  version :landscape_small do
    process :resize_to_fill => [300, 150]
  end

  version :square_large do
    process :resize_to_fill => [400, 400]
  end

  version :square_small do
    process :resize_to_fill => [200, 200]
  end

  version :portrait_large do
    process :resize_to_fill => [500, 700]
  end

  version :portrait_small do
    process :resize_to_fill => [250, 350]
  end

  version :thumb do
    process :resize_to_fill => [64, 64]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    if original_filename
      file_name, file_ext = original_filename.split('.')
      @str ||= Digest::MD5.hexdigest(file_name)
    end
    "#{@str}.#{file_ext}" if original_filename
  end

end
