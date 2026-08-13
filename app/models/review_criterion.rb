class ReviewCriterion < ApplicationRecord
  belongs_to :review_round
  default_scope { order(:position, :id) }
  KINDS = %w[number dropdown text].freeze
  validates :label, presence: true
  def option_list = Array(options)
end
