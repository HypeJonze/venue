class AddUserOAuthFields < ActiveRecord::Migration
  def change
    add_column  :users, :family_name, :string
    add_column  :users, :given_name, :string
    add_column  :users, :picture, :string
    add_column  :users, :admin, :boolean, :default => false
    add_column  :users, :logged_in_via_mobile, :boolean, :default => false
    add_column  :users, :logged_in_via_portal, :boolean, :default => false
  end
end
