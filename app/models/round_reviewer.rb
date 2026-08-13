# == Schema Information
#
# Table name: round_reviewers
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  review_round_id :integer          not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_round_reviewers_on_review_round_id  (review_round_id)
#  index_round_reviewers_on_user_id          (user_id)
#
# Foreign Keys
#
#  review_round_id  (review_round_id => review_rounds.id)
#  user_id          (user_id => users.id)
#
class RoundReviewer < ApplicationRecord
  belongs_to :review_round
  belongs_to :user
  validates :user_id, uniqueness: { scope: :review_round_id }
end
