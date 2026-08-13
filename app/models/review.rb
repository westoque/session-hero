# == Schema Information
#
# Table name: reviews
#
#  id              :integer          not null, primary key
#  ai_generated    :boolean          default(FALSE), not null
#  ai_rationale    :text
#  coi             :boolean          default(FALSE), not null
#  comment         :text
#  scores          :json
#  status          :string           default("pending"), not null
#  submitted_at    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  review_round_id :integer          not null
#  submission_id   :integer          not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_reviews_on_review_round_id  (review_round_id)
#  index_reviews_on_submission_id    (submission_id)
#  index_reviews_on_user_id          (user_id)
#
# Foreign Keys
#
#  review_round_id  (review_round_id => review_rounds.id)
#  submission_id    (submission_id => submissions.id)
#  user_id          (user_id => users.id)
#
class Review < ApplicationRecord
  belongs_to :review_round
  belongs_to :submission
  belongs_to :user
  default_scope { order(:id) }

  def scores = super || {}

  def numeric_average
    round = review_round
    vals = round.review_criteria.where(kind: "number").map { |c| scores.to_h[c.id.to_s].presence&.to_f }.compact
    vals.empty? ? nil : (vals.sum / vals.size).round(2)
  end

  def completed? = status == "completed"
end
