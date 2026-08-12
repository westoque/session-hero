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

ActiveRecord::Schema[8.1].define(version: 2026_08_12_044046) do
  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "event_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["event_id"], name: "index_event_memberships_on_event_id"
    t.index ["user_id", "event_id", "role"], name: "index_event_memberships_on_user_id_and_event_id_and_role", unique: true
    t.index ["user_id"], name: "index_event_memberships_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "cfp_closes_at"
    t.datetime "cfp_opens_at"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.text "description"
    t.date "ends_on"
    t.string "name"
    t.string "slug"
    t.date "starts_on"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["slug"], name: "index_events_on_slug", unique: true
  end

  create_table "mailkick_subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "list"
    t.integer "subscriber_id"
    t.string "subscriber_type"
    t.datetime "updated_at", null: false
    t.index ["subscriber_type", "subscriber_id", "list"], name: "index_mailkick_subscriptions_on_subscriber_and_list", unique: true
  end

  create_table "speaker_profiles", force: :cascade do |t|
    t.text "bio"
    t.string "company"
    t.datetime "created_at", null: false
    t.string "headline"
    t.string "job_title"
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_speaker_profiles_on_user_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.text "abstract"
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.integer "speaker_profile_id"
    t.string "status", default: "submitted", null: false
    t.string "talk_format"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["event_id"], name: "index_submissions_on_event_id"
    t.index ["speaker_profile_id"], name: "index_submissions_on_speaker_profile_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "event_memberships", "events"
  add_foreign_key "event_memberships", "users"
  add_foreign_key "events", "users", column: "created_by_id"
  add_foreign_key "speaker_profiles", "users"
  add_foreign_key "submissions", "events"
  add_foreign_key "submissions", "speaker_profiles"
  add_foreign_key "submissions", "users"
end
