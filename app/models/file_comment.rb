# == Schema Information
#
# Table name: file_comments
#
#  id             :integer          not null, primary key
#  author_name    :string
#  body           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deliverable_id :integer          not null
#  user_id        :integer
#
# Indexes
#
#  index_file_comments_on_deliverable_id  (deliverable_id)
#  index_file_comments_on_user_id         (user_id)
#
# Foreign Keys
#
#  deliverable_id  (deliverable_id => deliverables.id)
#  user_id         (user_id => users.id)
#
class FileComment < ApplicationRecord
  belongs_to :deliverable
  belongs_to :user, optional: true
  default_scope { order(:created_at) }
  validates :body, presence: true
  def display_author = author_name.presence || user&.display_name || "Someone"
end
