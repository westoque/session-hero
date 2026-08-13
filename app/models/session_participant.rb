class SessionParticipant < ApplicationRecord
  belongs_to :submission
  belongs_to :event_speaker
  default_scope { order(:position, :id) }
  validates :event_speaker_id, uniqueness: { scope: :submission_id }
end
