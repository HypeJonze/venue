class RemovePaperclipLogoFields < ActiveRecord::Migration
  def change
    remove_column :venues, :image_logo_file_name 
    remove_column :venues, :image_logo_content_type
    remove_column :venues, :image_logo_file_size
    remove_column :venues, :image_logo_updated_at
  end
end
