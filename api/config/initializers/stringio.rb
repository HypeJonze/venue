# Mimick an UploadedFile.
class FilelessIO < StringIO
  attr_accessor :original_filename
  attr_accessor :content_type
end