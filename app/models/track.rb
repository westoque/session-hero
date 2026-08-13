# == Schema Information
#
# Table name: tracks
#
#  id         :integer          not null, primary key
#  color      :string           default("#1560c7")
#  name       :string           not null
#  position   :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :integer          not null
#
# Indexes
#
#  index_tracks_on_event_id  (event_id)
#
# Foreign Keys
#
#  event_id  (event_id => events.id)
#
class Track < ApplicationRecord
  belongs_to :event
  has_many :submissions, dependent: :nullify
  validates :name, presence: true
  default_scope { order(:position, :id) }
  PALETTE = %w[#1560c7 #16a34a #f59e0b #9333ea #dc2626 #0891b2 #db2777 #4f46e5].freeze
end
