class CreateVenuesAndKeywordsJoinTable < ActiveRecord::Migration
  def change
    create_table :keywords_venues do |t|
      t.integer :venue_id
      t.integer :keyword_id
    end
  end
end