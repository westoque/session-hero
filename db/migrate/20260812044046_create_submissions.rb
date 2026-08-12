class CreateSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :submissions do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :speaker_profile, null: true, foreign_key: true
      t.string :title
      t.text :abstract
      t.string :status, null: false, default: "submitted"
      t.string :talk_format

      t.timestamps
    end
  end
end
