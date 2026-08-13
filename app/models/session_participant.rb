# == Schema Information
#
# Table name: session_participants
#
#  id               :integer          not null, primary key
#  position         :integer          default(0)
#  role             :string           default("Speaker")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  event_speaker_id :integer          not null
#  submission_id    :integer          not null
#
# Indexes
#
#  index_session_participants_on_event_speaker_id  (event_speaker_id)
#  index_session_participants_on_submission_id     (submission_id)
#
# Foreign Keys
#
#  event_speaker_id  (event_speaker_id => event_speakers.id)
#  submission_id     (submission_id => submissions.id)
#
class SessionParticipant < ApplicationRecord
  belongs_to :submission
  belongs_to :event_speaker
  default_scope { order(:position, :id) }
  validates :event_speaker_id, uniqueness: { scope: :submission_id }
end
