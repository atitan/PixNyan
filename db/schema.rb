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

ActiveRecord::Schema.define(version: 20140310102800) do

  create_table "posts", force: :cascade do |t|
    t.integer  "parent_post_id"
    t.string   "title",              limit: 255
    t.string   "author",             limit: 255
    t.string   "email",              limit: 255
    t.string   "real_ip",            limit: 255,                 null: false
    t.string   "remote_ip",          limit: 255,                 null: false
    t.string   "identity_hash",      limit: 255,                 null: false
    t.text     "message",                                        null: false
    t.string   "image_dimensions",   limit: 255
    t.string   "delete_password",    limit: 255
    t.boolean  "locked",                         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.index ["parent_post_id"], name: "index_posts_on_parent_post_id"
    t.index ["updated_at"], name: "index_posts_on_updated_at"
  end

end
