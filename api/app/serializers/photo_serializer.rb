class PhotoSerializer < ActiveModel::Serializer
  attributes :id, :image, :caption

  def image
    if !object.image.nil? and !object.image.url.nil?
      path_to_file = object.image.url.split('/')
      filename = path_to_file.pop
      {
        :versions => ["thumb_", "landscape_large_", "landscape_small_", "square_small_", "square_large_", "portrait_large_", "portrait_small_"],
        :filename => filename,
        :path => path_to_file.join('/') + "/"
      }
    end
  end
end
