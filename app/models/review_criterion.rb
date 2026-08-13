# == Schema Information
#
# Table name: review_criteria
#
#  id              :integer          not null, primary key
#  kind            :string           default("number"), not null
#  label           :string           not null
#  max_value       :integer          default(5)
#  min_value       :integer          default(1)
#  options         :json
#  position        :integer          default(0)
#  weight          :integer          default(1)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  review_round_id :integer          not null
#
# Indexes
#
#  index_review_criteria_on_review_round_id  (review_round_id)
#
# Foreign Keys
#
#  review_round_id  (review_round_id => review_rounds.id)
#
class ReviewCriterion < ApplicationRecord
  belongs_to :review_round
  attr_accessor :options_text
  default_scope { order(:position, :id) }
  KINDS = %w[number dropdown text].freeze
  validates :label, presence: true
  def option_list = Array(options)
end
