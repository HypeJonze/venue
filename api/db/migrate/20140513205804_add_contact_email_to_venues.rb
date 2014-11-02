class AddContactEmailToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :contact_email, :string
  end
end
