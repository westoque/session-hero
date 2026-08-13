# == Schema Information
#
# Table name: submission_versions
#
#  id            :integer          not null, primary key
#  abstract      :text
#  editor_name   :string
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  submission_id :integer          not null
#  user_id       :integer
#
# Indexes
#
#  index_submission_versions_on_submission_id  (submission_id)
#  index_submission_versions_on_user_id        (user_id)
#
# Foreign Keys
#
#  submission_id  (submission_id => submissions.id)
#  user_id        (user_id => users.id)
#
class SubmissionVersion < ApplicationRecord
  belongs_to :submission
  belongs_to :user, optional: true
  default_scope { order(created_at: :desc) }
  def display_editor = editor_name.presence || user&.display_name || "Someone"
end
