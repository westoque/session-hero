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
