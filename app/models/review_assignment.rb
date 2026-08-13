# == Schema Information
#
# Table name: review_assignments
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  review_round_id :integer          not null
#  submission_id   :integer          not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_review_assignments_on_review_round_id  (review_round_id)
#  index_review_assignments_on_submission_id    (submission_id)
#  index_review_assignments_on_user_id          (user_id)
#
# Foreign Keys
#
#  review_round_id  (review_round_id => review_rounds.id)
#  submission_id    (submission_id => submissions.id)
#  user_id          (user_id => users.id)
#
class ReviewAssignment < ApplicationRecord
  belongs_to :review_round
  belongs_to :submission
  belongs_to :user
  validates :submission_id, uniqueness: { scope: %i[review_round_id user_id] }
end
