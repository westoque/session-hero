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
