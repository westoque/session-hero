class ContactNote < ApplicationRecord
  belongs_to :contact
  belongs_to :user, optional: true
  default_scope { order(created_at: :desc) }
  def display_author = author_name.presence || user&.display_name || "Someone"
end
