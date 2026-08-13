class SpeakerCrm < ActiveRecord::Migration[8.1]
  def change
    # Org-level cross-event speaker directory (owned by an organizer user).
    create_table :contacts do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string  :name, null: false
      t.string  :email
      t.string  :company
      t.string  :job_title
      t.text    :bio
      t.string  :speaker_type              # Internal / External
      t.json    :tags
      t.json    :custom
      t.string  :pipeline_stage            # nil unless enrolled
      t.integer :pipeline_score
      t.text    :pipeline_rationale
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :contacts, %i[owner_id email]

    create_table :contact_notes do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string  :author_name
      t.text    :body
      t.string  :kind, default: "note"      # note / stage_change / email
      t.timestamps
    end

    create_table :segments do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string  :name, null: false
      t.json    :criteria
      t.timestamps
    end
  end
end
