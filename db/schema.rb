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

ActiveRecord::Schema.define(:version => 20131029163928) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.text     "description"
    t.string   "custom_url"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.integer  "user_id"
    t.boolean  "is_published",                                     :default => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "producer_id"
    t.text     "data_to_collect"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "theme"
    t.decimal  "fixed_fee",         :precision => 10, :scale => 0
    t.decimal  "percent_fee",       :precision => 10, :scale => 0
    t.boolean  "include_fee"
  end

  create_table "global_configurations", :force => true do |t|
    t.decimal  "fixed_fee",   :precision => 10, :scale => 0
    t.decimal  "percent_fee", :precision => 10, :scale => 0
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "nested_resources", :force => true do |t|
    t.string   "name"
    t.string   "last_name"
    t.string   "email"
    t.string   "rut"
    t.string   "phone"
    t.string   "mobile_phone"
    t.string   "address"
    t.string   "company"
    t.string   "job"
    t.string   "job_address"
    t.string   "job_phone"
    t.string   "website"
    t.boolean  "gender"
    t.date     "birthday"
    t.integer  "age"
    t.integer  "nestable_id"
    t.string   "nestable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "producers", :force => true do |t|
    t.string   "name"
    t.string   "rut"
    t.string   "address"
    t.string   "phone"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "description"
    t.string   "website"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.boolean  "confirmed",                                     :default => false
    t.string   "corporate_name"
    t.text     "brief"
    t.decimal  "fixed_fee",      :precision => 10, :scale => 0
    t.decimal  "percent_fee",    :precision => 10, :scale => 0
  end

  create_table "producers_users", :force => true do |t|
    t.integer "user_id"
    t.integer "producer_id"
  end

  create_table "promotions", :force => true do |t|
    t.string   "name"
    t.string   "promotion_type"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "limit"
    t.string   "activation_code"
    t.decimal  "promotion_type_config", :precision => 10, :scale => 0
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.boolean  "enabled",                                              :default => true
    t.integer  "promotable_id"
    t.string   "promotable_type"
  end

  create_table "ticket_types", :force => true do |t|
    t.integer  "event_id"
    t.string   "name"
    t.integer  "price"
    t.integer  "quantity"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tickets", :force => true do |t|
    t.integer  "ticket_type_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "transaction_id"
    t.integer  "promotion_id"
  end

  create_table "transactions", :force => true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.string   "payment_status"
    t.decimal  "amount",           :precision => 10, :scale => 0
    t.datetime "transaction_time"
    t.string   "details"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "error"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",     :null => false
    t.string   "encrypted_password",     :default => "",     :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "role",                   :default => "user"
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
