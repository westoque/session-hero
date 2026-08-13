class ReviewRound < ApplicationRecord
  belongs_to :event
  has_many :review_criteria, dependent: :destroy
  has_many :round_reviewers, dependent: :destroy
  has_many :reviewers, through: :round_reviewers, source: :user
  has_many :review_assignments, dependent: :destroy
  has_many :reviews, dependent: :destroy
  default_scope { order(:position, :id) }

  accepts_nested_attributes_for :review_criteria, allow_destroy: true

  validates :name, presence: true

  def assignments_for(user) = review_assignments.where(user: user)

  def submissions_for(user)
    Submission.where(id: assignments_for(user).select(:submission_id))
  end

  def weighted_average(submission)
    rs = reviews.where(submission: submission, status: "completed").where(coi: false)
    return nil if rs.empty?
    numer = 0.0; denom = 0.0
    review_criteria.where(kind: "number").each do |c|
      vals = rs.map { |r| r.scores.to_h[c.id.to_s].presence&.to_f }.compact
      next if vals.empty?
      avg = vals.sum / vals.size
      numer += avg * c.weight
      denom += c.weight
    end
    denom.zero? ? nil : (numer / denom).round(2)
  end

  def unweighted_average(submission)
    rs = reviews.where(submission: submission, status: "completed").where(coi: false)
    return nil if rs.empty?
    vals = []
    review_criteria.where(kind: "number").each do |c|
      rs.each { |r| v = r.scores.to_h[c.id.to_s]; vals << v.to_f if v.present? }
    end
    vals.empty? ? nil : (vals.sum / vals.size).round(2)
  end

  def completed_count(user) = reviews.where(user: user, status: "completed").count
  def assigned_count(user)  = review_assignments.where(user: user).count
end
