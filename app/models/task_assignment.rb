class TaskAssignment < ApplicationRecord
  belongs_to :portal_task
  belongs_to :event_speaker
  validates :event_speaker_id, uniqueness: { scope: :portal_task_id }

  def completed? = completed_at.present?
  def status = completed? ? "complete" : "incomplete"
  def complete! = update!(completed_at: Time.current)
  def reopen!   = update!(completed_at: nil)
end
