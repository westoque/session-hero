class SubmissionVersion < ApplicationRecord
  belongs_to :submission
  belongs_to :user, optional: true
  default_scope { order(created_at: :desc) }
  def display_editor = editor_name.presence || user&.display_name || "Someone"
end
