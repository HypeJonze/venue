class CreateCategoriesAndVenueTypesJoinTable < ActiveRecord::Migration
  def change
    create_table :categories_venue_types do |t|
      t.integer :venue_type_id
      t.integer :category_id
    end
  end
end