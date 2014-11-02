class Photo < ActiveRecord::Base
  belongs_to :venue

  mount_uploader :image, ImageUploader
end
