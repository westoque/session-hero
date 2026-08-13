class Track < ApplicationRecord
  belongs_to :event
  has_many :submissions, dependent: :nullify
  validates :name, presence: true
  default_scope { order(:position, :id) }
  PALETTE = %w[#1560c7 #16a34a #f59e0b #9333ea #dc2626 #0891b2 #db2777 #4f46e5].freeze
end
