# == Schema Information
#
# Table name: rooms
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  position   :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :integer          not null
#
# Indexes
#
#  index_rooms_on_event_id  (event_id)
#
# Foreign Keys
#
#  event_id  (event_id => events.id)
#
class Room < ApplicationRecord
  belongs_to :event
  has_many :submissions, dependent: :nullify
  validates :name, presence: true
  default_scope { order(:position, :id) }
end
