class FileComment < ApplicationRecord
  belongs_to :deliverable
  belongs_to :user, optional: true
  default_scope { order(:created_at) }
  validates :body, presence: true
  def display_author = author_name.presence || user&.display_name || "Someone"
end
