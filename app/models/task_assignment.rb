# == Schema Information
#
# Table name: task_assignments
#
#  id               :integer          not null, primary key
#  completed_at     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  event_speaker_id :integer          not null
#  portal_task_id   :integer          not null
#
# Indexes
#
#  index_task_assignments_on_event_speaker_id  (event_speaker_id)
#  index_task_assignments_on_portal_task_id    (portal_task_id)
#
# Foreign Keys
#
#  event_speaker_id  (event_speaker_id => event_speakers.id)
#  portal_task_id    (portal_task_id => portal_tasks.id)
#
class TaskAssignment < ApplicationRecord
  belongs_to :portal_task
  belongs_to :event_speaker
  validates :event_speaker_id, uniqueness: { scope: :portal_task_id }

  def completed? = completed_at.present?
  def status = completed? ? "complete" : "incomplete"
  def complete! = update!(completed_at: Time.current)
  def reopen!   = update!(completed_at: nil)
end
