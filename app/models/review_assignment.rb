class ReviewAssignment < ApplicationRecord
  belongs_to :review_round
  belongs_to :submission
  belongs_to :user
  validates :submission_id, uniqueness: { scope: %i[review_round_id user_id] }
end
