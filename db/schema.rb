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

ActiveRecord::Schema[8.1].define(version: 2026_08_13_043307) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "communication_logs", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "event_id"
    t.string "kind", default: "email"
    t.json "recipients"
    t.datetime "sent_at"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["event_id"], name: "index_communication_logs_on_event_id"
    t.index ["user_id"], name: "index_communication_logs_on_user_id"
  end

  create_table "contact_notes", force: :cascade do |t|
    t.string "author_name"
    t.text "body"
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.string "kind", default: "note"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["contact_id"], name: "index_contact_notes_on_contact_id"
    t.index ["user_id"], name: "index_contact_notes_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.text "bio"
    t.string "company"
    t.datetime "created_at", null: false
    t.json "custom"
    t.string "email"
    t.string "job_title"
    t.string "name", null: false
    t.integer "owner_id", null: false
    t.text "pipeline_rationale"
    t.integer "pipeline_score"
    t.string "pipeline_stage"
    t.integer "position", default: 0
    t.string "speaker_type"
    t.json "tags"
    t.datetime "updated_at", null: false
    t.index ["owner_id", "email"], name: "index_contacts_on_owner_id_and_email"
    t.index ["owner_id"], name: "index_contacts_on_owner_id"
  end

  create_table "deliverables", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_speaker_id"
    t.string "kind", default: "presentation"
    t.integer "portal_task_id"
    t.integer "submission_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["event_speaker_id"], name: "index_deliverables_on_event_speaker_id"
    t.index ["portal_task_id"], name: "index_deliverables_on_portal_task_id"
    t.index ["submission_id"], name: "index_deliverables_on_submission_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "event_id"
    t.string "name"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_email_templates_on_event_id"
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

  create_table "event_speakers", force: :cascade do |t|
    t.text "bio"
    t.string "company"
    t.datetime "created_at", null: false
    t.json "custom"
    t.string "email"
    t.integer "event_id", null: false
    t.string "linkedin"
    t.string "name", null: false
    t.integer "position", default: 0
    t.boolean "public_visible", default: true, null: false
    t.boolean "returning", default: false, null: false
    t.string "status", default: "invited", null: false
    t.string "title"
    t.text "travel_notes"
    t.string "twitter"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["event_id", "email"], name: "index_event_speakers_on_event_id_and_email"
    t.index ["event_id"], name: "index_event_speakers_on_event_id"
    t.index ["user_id"], name: "index_event_speakers_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "agenda_published", default: false, null: false
    t.datetime "cfp_closes_at"
    t.datetime "cfp_opens_at"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.text "description"
    t.date "ends_on"
    t.string "event_type", default: "Conference"
    t.string "location"
    t.string "name"
    t.json "session_formats"
    t.string "slug"
    t.date "starts_on"
    t.string "status", default: "draft", null: false
    t.string "tagline"
    t.text "theme"
    t.string "timezone", default: "America/Los_Angeles"
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["slug"], name: "index_events_on_slug", unique: true
  end

  create_table "file_comments", force: :cascade do |t|
    t.string "author_name"
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "deliverable_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["deliverable_id"], name: "index_file_comments_on_deliverable_id"
    t.index ["user_id"], name: "index_file_comments_on_user_id"
  end

  create_table "file_versions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "deliverable_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_number", default: 1
    t.index ["deliverable_id"], name: "index_file_versions_on_deliverable_id"
  end

  create_table "form_fields", force: :cascade do |t|
    t.bigint "conditional_field_id"
    t.string "conditional_value"
    t.datetime "created_at", null: false
    t.string "field_type", default: "short_text", null: false
    t.text "help_text"
    t.string "label", null: false
    t.json "options"
    t.integer "position", default: 0
    t.boolean "required", default: false, null: false
    t.integer "submission_form_id", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_form_id"], name: "index_form_fields_on_submission_form_id"
  end

  create_table "mailkick_subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "list"
    t.integer "subscriber_id"
    t.string "subscriber_type"
    t.datetime "updated_at", null: false
    t.index ["subscriber_type", "subscriber_id", "list"], name: "index_mailkick_subscriptions_on_subscriber_and_list", unique: true
  end

  create_table "portal_tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_on"
    t.integer "event_id", null: false
    t.string "external_link"
    t.integer "position", default: 0
    t.boolean "required", default: false, null: false
    t.string "task_type", default: "general", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_portal_tasks_on_event_id"
  end

  create_table "review_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "review_round_id", null: false
    t.integer "submission_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["review_round_id"], name: "index_review_assignments_on_review_round_id"
    t.index ["submission_id"], name: "index_review_assignments_on_submission_id"
    t.index ["user_id"], name: "index_review_assignments_on_user_id"
  end

  create_table "review_criteria", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind", default: "number", null: false
    t.string "label", null: false
    t.integer "max_value", default: 5
    t.integer "min_value", default: 1
    t.json "options"
    t.integer "position", default: 0
    t.integer "review_round_id", null: false
    t.datetime "updated_at", null: false
    t.integer "weight", default: 1
    t.index ["review_round_id"], name: "index_review_criteria_on_review_round_id"
  end

  create_table "review_rounds", force: :cascade do |t|
    t.boolean "anonymized", default: false, null: false
    t.datetime "closes_at"
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.text "instructions"
    t.string "name", null: false
    t.datetime "opens_at"
    t.integer "position", default: 0
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_review_rounds_on_event_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.boolean "ai_generated", default: false, null: false
    t.text "ai_rationale"
    t.boolean "coi", default: false, null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "review_round_id", null: false
    t.json "scores"
    t.string "status", default: "pending", null: false
    t.integer "submission_id", null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["review_round_id"], name: "index_reviews_on_review_round_id"
    t.index ["submission_id"], name: "index_reviews_on_submission_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_rooms_on_event_id"
  end

  create_table "round_reviewers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "review_round_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["review_round_id"], name: "index_round_reviewers_on_review_round_id"
    t.index ["user_id"], name: "index_round_reviewers_on_user_id"
  end

  create_table "segments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "criteria"
    t.string "name", null: false
    t.integer "owner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_segments_on_owner_id"
  end

  create_table "session_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_speaker_id", null: false
    t.integer "position", default: 0
    t.string "role", default: "Speaker"
    t.integer "submission_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_speaker_id"], name: "index_session_participants_on_event_speaker_id"
    t.index ["submission_id"], name: "index_session_participants_on_submission_id"
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

  create_table "submission_forms", force: :cascade do |t|
    t.datetime "closes_at"
    t.text "confirmation_message"
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.string "name"
    t.integer "position", default: 0
    t.boolean "published", default: true, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.text "welcome_message"
    t.index ["event_id"], name: "index_submission_forms_on_event_id"
  end

  create_table "submission_versions", force: :cascade do |t|
    t.text "abstract"
    t.datetime "created_at", null: false
    t.string "editor_name"
    t.integer "submission_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["submission_id"], name: "index_submission_versions_on_submission_id"
    t.index ["user_id"], name: "index_submission_versions_on_user_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.text "abstract"
    t.json "answers"
    t.string "audience_level"
    t.string "content_status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.integer "event_id", null: false
    t.integer "event_speaker_id"
    t.string "key_takeaway"
    t.integer "position", default: 0
    t.boolean "public_visible", default: true, null: false
    t.integer "room_id"
    t.integer "speaker_profile_id"
    t.datetime "starts_at"
    t.string "status", default: "submitted", null: false
    t.integer "submission_form_id"
    t.string "talk_format"
    t.string "title"
    t.integer "track_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["event_id"], name: "index_submissions_on_event_id"
    t.index ["event_speaker_id"], name: "index_submissions_on_event_speaker_id"
    t.index ["room_id"], name: "index_submissions_on_room_id"
    t.index ["speaker_profile_id"], name: "index_submissions_on_speaker_profile_id"
    t.index ["submission_form_id"], name: "index_submissions_on_submission_form_id"
    t.index ["track_id"], name: "index_submissions_on_track_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "task_assignments", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "event_speaker_id", null: false
    t.integer "portal_task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_speaker_id"], name: "index_task_assignments_on_event_speaker_id"
    t.index ["portal_task_id"], name: "index_task_assignments_on_portal_task_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "color", default: "#1560c7"
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_tracks_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "communication_logs", "events"
  add_foreign_key "communication_logs", "users"
  add_foreign_key "contact_notes", "contacts"
  add_foreign_key "contact_notes", "users"
  add_foreign_key "contacts", "users", column: "owner_id"
  add_foreign_key "deliverables", "event_speakers"
  add_foreign_key "deliverables", "portal_tasks"
  add_foreign_key "deliverables", "submissions"
  add_foreign_key "email_templates", "events"
  add_foreign_key "event_memberships", "events"
  add_foreign_key "event_memberships", "users"
  add_foreign_key "event_speakers", "events"
  add_foreign_key "event_speakers", "users"
  add_foreign_key "events", "users", column: "created_by_id"
  add_foreign_key "file_comments", "deliverables"
  add_foreign_key "file_comments", "users"
  add_foreign_key "file_versions", "deliverables"
  add_foreign_key "form_fields", "submission_forms"
  add_foreign_key "portal_tasks", "events"
  add_foreign_key "review_assignments", "review_rounds"
  add_foreign_key "review_assignments", "submissions"
  add_foreign_key "review_assignments", "users"
  add_foreign_key "review_criteria", "review_rounds"
  add_foreign_key "review_rounds", "events"
  add_foreign_key "reviews", "review_rounds"
  add_foreign_key "reviews", "submissions"
  add_foreign_key "reviews", "users"
  add_foreign_key "rooms", "events"
  add_foreign_key "round_reviewers", "review_rounds"
  add_foreign_key "round_reviewers", "users"
  add_foreign_key "segments", "users", column: "owner_id"
  add_foreign_key "session_participants", "event_speakers"
  add_foreign_key "session_participants", "submissions"
  add_foreign_key "speaker_profiles", "users"
  add_foreign_key "submission_forms", "events"
  add_foreign_key "submission_versions", "submissions"
  add_foreign_key "submission_versions", "users"
  add_foreign_key "submissions", "event_speakers"
  add_foreign_key "submissions", "events"
  add_foreign_key "submissions", "rooms"
  add_foreign_key "submissions", "speaker_profiles"
  add_foreign_key "submissions", "submission_forms"
  add_foreign_key "submissions", "tracks"
  add_foreign_key "submissions", "users"
  add_foreign_key "task_assignments", "event_speakers"
  add_foreign_key "task_assignments", "portal_tasks"
  add_foreign_key "tracks", "events"
end
