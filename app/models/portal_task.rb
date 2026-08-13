class PortalTask < ApplicationRecord
  belongs_to :event
  has_many :task_assignments, dependent: :destroy
  has_many :event_speakers, through: :task_assignments
  has_many :deliverables, dependent: :nullify
  default_scope { order(:position, :id) }

  TASK_TYPES = %w[general file_request].freeze
  validates :title, presence: true

  def file_request? = task_type == "file_request"
  def completed_count = task_assignments.where.not(completed_at: nil).count
  def total_count = task_assignments.count
end
