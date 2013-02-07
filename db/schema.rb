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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130117152449) do

  create_table "checks", :force => true do |t|
    t.integer  "team_id",    :null => false
    t.integer  "server_id",  :null => false
    t.integer  "service_id", :null => false
    t.boolean  "passed",     :null => false
    t.text     "request",    :null => false
    t.text     "response",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "username",        :null => false
    t.string   "password_digest", :null => false
    t.integer  "team_id",         :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "properties", :force => true do |t|
    t.integer  "team_id",    :null => false
    t.integer  "server_id",  :null => false
    t.integer  "service_id", :null => false
    t.string   "category",   :null => false
    t.string   "property",   :null => false
    t.text     "value",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "servers", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "team_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "services", :force => true do |t|
    t.integer  "team_id",          :null => false
    t.integer  "server_id",        :null => false
    t.string   "name",             :null => false
    t.string   "protocol",         :null => false
    t.string   "version",          :null => false
    t.boolean  "enabled",          :null => false
    t.integer  "points_per_check", :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "alias",      :null => false
    t.string   "name",       :null => false
    t.string   "color",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "team_id",    :null => false
    t.integer  "server_id",  :null => false
    t.integer  "service_id", :null => false
    t.string   "username",   :null => false
    t.string   "password",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
