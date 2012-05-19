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

ActiveRecord::Schema.define(:version => 20111206015647) do

  create_table "entries", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "title",      :null => false
    t.text     "reflection", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entries", ["user_id"], :name => "index_entries_on_user_id"

  create_table "entries_tags", :id => false, :force => true do |t|
    t.integer  "entry_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entry_evidence", :force => true do |t|
    t.integer  "entry_id",   :null => false
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entry_evidence", ["entry_id"], :name => "index_evidence_on_entry_id"

  create_table "recommendation_evidence", :force => true do |t|
    t.integer  "recommendation_id", :null => false
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", :force => true do |t|
    t.integer  "entry_id",                        :null => false
    t.integer  "user_id",                         :null => false
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid",                            :null => false
    t.string   "status",       :default => "NEW"
    t.string   "feedback"
    t.string   "relationship"
  end

  add_index "recommendations", ["entry_id"], :name => "index_testimonials_on_entry_id"
  add_index "recommendations", ["user_id"], :name => "index_testimonials_on_user_id"
  add_index "recommendations", ["uuid"], :name => "index_testimonials_on_uuid", :unique => true

  create_table "recommendations_tags", :id => false, :force => true do |t|
    t.integer  "recommendation_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authentication_token"
    t.string   "user_type",                                             :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
