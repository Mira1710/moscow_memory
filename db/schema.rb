# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_06_194555) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "historical_states", force: :cascade do |t|
    t.bigint "place_id", null: false
    t.string "title"
    t.text "description"
    t.integer "year_from"
    t.integer "year_to"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_historical_states_on_place_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "address"
    t.decimal "latitude"
    t.decimal "longitude"
    t.integer "year_from"
    t.integer "year_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
  end

  add_foreign_key "historical_states", "places"
end
