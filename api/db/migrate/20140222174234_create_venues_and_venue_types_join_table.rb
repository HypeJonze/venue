class CreateVenuesAndVenueTypesJoinTable < ActiveRecord::Migration
  def change
    create_table :venue_types_venues do |t|
      t.integer :venue_type_id
      t.integer :venue_id
    end
  end
end