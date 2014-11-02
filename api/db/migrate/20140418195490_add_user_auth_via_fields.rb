class AddUserAuthViaFields < ActiveRecord::Migration
  def change
    add_column  :users, :auth_via_mobile, :boolean, :default => false
    add_column  :users, :auth_via_web, :boolean, :default => false
  end
end
