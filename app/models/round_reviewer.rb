class RoundReviewer < ApplicationRecord
  belongs_to :review_round
  belongs_to :user
  validates :user_id, uniqueness: { scope: :review_round_id }
end
