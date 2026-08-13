# == Schema Information
#
# Table name: deliverables
#
#  id               :integer          not null, primary key
#  kind             :string           default("presentation")
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  event_speaker_id :integer
#  portal_task_id   :integer
#  submission_id    :integer
#
# Indexes
#
#  index_deliverables_on_event_speaker_id  (event_speaker_id)
#  index_deliverables_on_portal_task_id    (portal_task_id)
#  index_deliverables_on_submission_id     (submission_id)
#
# Foreign Keys
#
#  event_speaker_id  (event_speaker_id => event_speakers.id)
#  portal_task_id    (portal_task_id => portal_tasks.id)
#  submission_id     (submission_id => submissions.id)
#
class Deliverable < ApplicationRecord
  belongs_to :submission, optional: true
  belongs_to :event_speaker, optional: true
  belongs_to :portal_task, optional: true
  has_many :file_versions, dependent: :destroy
  has_many :file_comments, dependent: :destroy
  default_scope { order(:id) }

  KINDS = %w[presentation poster handout].freeze

  def latest_version = file_versions.order(:version_number).last
  def version_count = file_versions.count

  def add_version!(file)
    n = (file_versions.maximum(:version_number) || 0) + 1
    v = file_versions.create!(version_number: n)
    v.file.attach(file)
    v
  end
end
