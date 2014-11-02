class CreateVenueTypesAndKeywordsJoinTable < ActiveRecord::Migration
  def change
    create_table :keywords_venue_types do |t|
      t.integer :venue_type_id
      t.integer :keyword_id
    end
  end
end