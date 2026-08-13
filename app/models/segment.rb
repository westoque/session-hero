# == Schema Information
#
# Table name: segments
#
#  id         :integer          not null, primary key
#  criteria   :json
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :integer          not null
#
# Indexes
#
#  index_segments_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  owner_id  (owner_id => users.id)
#
class Segment < ApplicationRecord
  belongs_to :owner, class_name: "User"
  default_scope { order(:name) }
  validates :name, presence: true
  def criteria_hash = (criteria || {}).to_h
end
