class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.date :starts_on
      t.date :ends_on
      t.datetime :cfp_opens_at
      t.datetime :cfp_closes_at
      t.string :status, null: false, default: "draft"
      t.references :created_by, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :events, :slug, unique: true
  end
end
