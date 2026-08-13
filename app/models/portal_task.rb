# == Schema Information
#
# Table name: portal_tasks
#
#  id            :integer          not null, primary key
#  description   :text
#  due_on        :date
#  external_link :string
#  position      :integer          default(0)
#  required      :boolean          default(FALSE), not null
#  task_type     :string           default("general"), not null
#  title         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  event_id      :integer          not null
#
# Indexes
#
#  index_portal_tasks_on_event_id  (event_id)
#
# Foreign Keys
#
#  event_id  (event_id => events.id)
#
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
