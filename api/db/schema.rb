# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140513205804) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_venue_types", force: true do |t|
    t.integer "venue_type_id"
    t.integer "category_id"
  end

  create_table "keywords", force: true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords_venue_types", force: true do |t|
    t.integer "venue_type_id"
    t.integer "keyword_id"
  end

  create_table "keywords_venues", force: true do |t|
    t.integer "venue_id"
    t.integer "keyword_id"
  end

  create_table "neighbourhoods", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", force: true do |t|
    t.string   "caption"
    t.string   "image"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                                null: false
    t.string   "password_digest"
    t.string   "api_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "family_name"
    t.string   "given_name"
    t.string   "picture"
    t.boolean  "logged_in_via_mobile", default: false
    t.boolean  "logged_in_via_portal", default: false
    t.boolean  "auth_via_mobile",      default: false
    t.boolean  "auth_via_web",         default: false
    t.string   "role"
  end

  add_index "users", ["api_token"], name: "index_users_on_api_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true

  create_table "venue_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venue_types_venues", force: true do |t|
    t.integer "venue_type_id"
    t.integer "venue_id"
  end

  create_table "venues", force: true do |t|
    t.integer  "neighbourhood_id"
    t.string   "name"
    t.text     "description"
    t.string   "address"
    t.string   "address_secondary"
    t.string   "intersection"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.string   "food"
    t.string   "music"
    t.string   "dress_code"
    t.string   "entry_fee"
    t.string   "style"
    t.string   "crowd"
    t.string   "specialty"
    t.text     "specials"
    t.string   "price_range"
    t.string   "parking"
    t.string   "hours"
    t.string   "date"
    t.string   "contact_phone"
    t.boolean  "enabled"
    t.boolean  "featured"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.integer  "user_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "contact_email"
  end

  add_index "venues", ["latitude", "longitude"], name: "index_venues_on_latitude_and_longitude"

end
