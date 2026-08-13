class Segment < ApplicationRecord
  belongs_to :owner, class_name: "User"
  default_scope { order(:name) }
  validates :name, presence: true
  def criteria_hash = (criteria || {}).to_h
end
