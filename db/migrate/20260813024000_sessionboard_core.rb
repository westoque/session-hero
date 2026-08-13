class SessionboardCore < ActiveRecord::Migration[8.1]
  def change
    # ── Event enrichment ─────────────────────────────────────────────
    change_table :events, bulk: true do |t|
      t.string  :location
      t.string  :timezone,     default: "America/Los_Angeles"
      t.string  :website_url
      t.string  :event_type,   default: "Conference"
      t.string  :tagline
      t.text    :theme
      t.json    :session_formats             # array of format strings
      t.boolean :agenda_published, default: false, null: false
    end

    # ── Tracks & Rooms ───────────────────────────────────────────────
    create_table :tracks do |t|
      t.references :event, null: false, foreign_key: true
      t.string  :name, null: false
      t.string  :color, default: "#1560c7"
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :rooms do |t|
      t.references :event, null: false, foreign_key: true
      t.string  :name, null: false
      t.integer :position, default: 0
      t.timestamps
    end

    # ── Event speakers (roster / contact-in-event) ───────────────────
    create_table :event_speakers do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, foreign_key: true            # nullable link to app login
      t.string  :name, null: false
      t.string  :email
      t.string  :title
      t.string  :company
      t.text    :bio
      t.string  :twitter
      t.string  :linkedin
      t.string  :status, default: "invited", null: false
      t.text    :travel_notes
      t.json    :custom
      t.boolean :public_visible, default: true, null: false
      t.boolean :returning, default: false, null: false
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :event_speakers, %i[event_id email]

    # ── Form builder (created before submissions alter: FK target) ───
    create_table :submission_forms do |t|
      t.references :event, null: false, foreign_key: true
      t.string  :name                           # internal name
      t.string  :title                          # external title
      t.text    :welcome_message
      t.text    :confirmation_message
      t.datetime :closes_at
      t.boolean :published, default: true, null: false
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :form_fields do |t|
      t.references :submission_form, null: false, foreign_key: true
      t.string  :label, null: false
      t.string  :field_type, default: "short_text", null: false
      t.boolean :required, default: false, null: false
      t.text    :help_text
      t.json    :options                        # dropdown/checkbox options
      t.integer :position, default: 0
      t.bigint  :conditional_field_id           # show when this field ...
      t.string  :conditional_value              # ... equals this value
      t.timestamps
    end

    # ── Submission (session record) enrichment ───────────────────────
    change_table :submissions, bulk: true do |t|
      t.references :track, foreign_key: true
      t.references :room, foreign_key: true
      t.references :event_speaker, foreign_key: true
      t.references :submission_form, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.string   :content_status, default: "draft", null: false  # draft/in_review/approved
      t.boolean  :public_visible, default: true, null: false
      t.integer  :position, default: 0
      t.string   :audience_level
      t.string   :key_takeaway
      t.json      :answers                       # custom form field answers
    end

    # ── Co-speakers / participants ───────────────────────────────────
    create_table :session_participants do |t|
      t.references :submission, null: false, foreign_key: true
      t.references :event_speaker, null: false, foreign_key: true
      t.string  :role, default: "Speaker"
      t.integer :position, default: 0
      t.timestamps
    end

    # ── Evaluation (rounds, scorecards, assignments, reviews) ────────
    create_table :review_rounds do |t|
      t.references :event, null: false, foreign_key: true
      t.string  :name, null: false
      t.text    :instructions
      t.datetime :opens_at
      t.datetime :closes_at
      t.boolean :anonymized, default: false, null: false
      t.string  :status, default: "open", null: false
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :review_criteria do |t|
      t.references :review_round, null: false, foreign_key: true
      t.string  :label, null: false
      t.string  :kind, default: "number", null: false   # number/dropdown/text
      t.integer :min_value, default: 1
      t.integer :max_value, default: 5
      t.integer :weight, default: 1
      t.json    :options
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :round_reviewers do |t|
      t.references :review_round, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    create_table :review_assignments do |t|
      t.references :review_round, null: false, foreign_key: true
      t.references :submission, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true   # reviewer
      t.timestamps
    end

    create_table :reviews do |t|
      t.references :review_round, null: false, foreign_key: true
      t.references :submission, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true   # reviewer
      t.string  :status, default: "pending", null: false
      t.boolean :coi, default: false, null: false
      t.boolean :ai_generated, default: false, null: false
      t.text    :comment
      t.json    :scores                          # {criterion_id => value}
      t.text    :ai_rationale
      t.datetime :submitted_at
      t.timestamps
    end

    # ── Portal tasks & assignments ───────────────────────────────────
    create_table :portal_tasks do |t|
      t.references :event, null: false, foreign_key: true
      t.string  :title, null: false
      t.text    :description
      t.date    :due_on
      t.string  :task_type, default: "general", null: false  # general/file_request
      t.boolean :required, default: false, null: false
      t.string  :external_link
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :task_assignments do |t|
      t.references :portal_task, null: false, foreign_key: true
      t.references :event_speaker, null: false, foreign_key: true
      t.datetime :completed_at
      t.timestamps
    end

    # ── Deliverables (session files, versions, comments) ─────────────
    create_table :deliverables do |t|
      t.references :submission, foreign_key: true
      t.references :event_speaker, foreign_key: true
      t.references :portal_task, foreign_key: true
      t.string  :title
      t.string  :kind, default: "presentation"   # presentation/poster/handout
      t.timestamps
    end

    create_table :file_versions do |t|
      t.references :deliverable, null: false, foreign_key: true
      t.integer :version_number, default: 1
      t.timestamps
    end

    create_table :file_comments do |t|
      t.references :deliverable, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string  :author_name
      t.text    :body
      t.timestamps
    end

    # ── Content change history ───────────────────────────────────────
    create_table :submission_versions do |t|
      t.references :submission, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string  :editor_name
      t.string  :title
      t.text    :abstract
      t.timestamps
    end

    # ── Communications ───────────────────────────────────────────────
    create_table :email_templates do |t|
      t.references :event, foreign_key: true
      t.string  :name
      t.string  :subject
      t.text    :body
      t.timestamps
    end

    create_table :communication_logs do |t|
      t.references :event, foreign_key: true
      t.references :user, foreign_key: true
      t.string  :subject
      t.text    :body
      t.json    :recipients                      # [{name,email}]
      t.string  :kind, default: "email"
      t.datetime :sent_at
      t.timestamps
    end
  end
end
