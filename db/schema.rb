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

ActiveRecord::Schema.define(version: 20170308071157) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "recipes", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "source"
    t.string   "category"
    t.string   "prep_time"
    t.string   "servings"
    t.string   "cals_serving"
    t.binary   "attachments"
    t.string   "notes"
    t.string   "ingredient1"
    t.string   "ingredient2"
    t.string   "ingredient3"
    t.string   "ingredient4"
    t.string   "ingredient5"
    t.string   "ingredient6"
    t.string   "ingredient7"
    t.string   "ingredient8"
    t.string   "ingredient9"
    t.string   "ingredient10"
    t.string   "ingredient11"
    t.string   "ingredient12"
    t.string   "ingredient13"
    t.string   "ingredient14"
    t.string   "ingredient15"
    t.string   "ingredient16"
    t.string   "ingredient17"
    t.string   "ingredient18"
    t.string   "ingredient19"
    t.string   "ingredient20"
    t.string   "ingredient21"
    t.string   "ingredient22"
    t.string   "quantity1"
    t.string   "quantity2"
    t.string   "quantity3"
    t.string   "quantity4"
    t.string   "quantity5"
    t.string   "quantity6"
    t.string   "quantity7"
    t.string   "quantity8"
    t.string   "quantity9"
    t.string   "quantity10"
    t.string   "quantity11"
    t.string   "quantity12"
    t.string   "quantity13"
    t.string   "quantity14"
    t.string   "quantity15"
    t.string   "quantity16"
    t.string   "quantity17"
    t.string   "quantity18"
    t.string   "quantity19"
    t.string   "quantity20"
    t.string   "quantity21"
    t.string   "quantity22"
    t.text     "instruction1"
    t.text     "instruction2"
    t.text     "instruction3"
    t.text     "instruction4"
    t.text     "instruction5"
    t.text     "instruction6"
    t.text     "instruction7"
    t.text     "instruction8"
    t.text     "instruction9"
    t.text     "instruction10"
    t.text     "instruction11"
    t.text     "instruction12"
    t.text     "instruction13"
    t.text     "instruction14"
    t.text     "instruction15"
    t.text     "instruction16"
    t.text     "instruction17"
    t.text     "instruction18"
    t.text     "instruction19"
    t.text     "instruction20"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name_string"
    t.string   "email"
    t.string   "password_hash"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end
