class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.belongs_to :neighbourhood
      t.string  :name
      t.text    :description
      t.string  :address
      t.string  :address_secondary
      t.string  :intersection
      t.string  :city
      t.string  :state
      t.string  :country
      t.string  :zip
      t.string  :food
      t.string  :music
      t.string  :dress_code
      t.string  :entry_fee
      t.string  :style
      t.string  :crowd
      t.string  :specialty
      t.text    :specials
      t.string  :price_range
      t.string  :parking
      t.string  :hours
      t.string  :date            
      t.string  :contact_phone
      t.boolean :enabled
      t.boolean :featured
      t.timestamps
    end
    add_attachment :venues, :image_logo
  end
end
