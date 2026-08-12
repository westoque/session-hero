# == Schema Information
#
# Table name: event_memberships
#
#  id         :integer          not null, primary key
#  role       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_event_memberships_on_event_id                       (event_id)
#  index_event_memberships_on_user_id                        (user_id)
#  index_event_memberships_on_user_id_and_event_id_and_role  (user_id,event_id,role) UNIQUE
#
# Foreign Keys
#
#  event_id  (event_id => events.id)
#  user_id   (user_id => users.id)
#
class EventMembership < ApplicationRecord
  belongs_to :user
  belongs_to :event

  # A person's role is scoped to a single event. One user can hold several roles
  # at one event (organizer + speaker), so uniqueness is on [user, event, role].
  enum :role, { organizer: "organizer", speaker: "speaker", reviewer: "reviewer" }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: %i[event_id role] }
end
