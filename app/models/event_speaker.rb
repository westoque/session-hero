class EventSpeaker < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true
  has_one_attached :headshot

  has_many :session_participants, dependent: :destroy
  has_many :submissions, through: :session_participants
  has_many :task_assignments, dependent: :destroy
  has_many :portal_tasks, through: :task_assignments
  has_many :deliverables, dependent: :nullify

  STATUSES = %w[invited confirmed accepted declined].freeze
  validates :name, presence: true

  default_scope { order(:position, :name) }
  scope :public_visible, -> { where(public_visible: true) }

  def initials
    name.to_s.split.map(&:first).first(2).join.upcase.presence || "?"
  end

  # Sessions this speaker actually presents (accepted/scheduled), for portal + public.
  def sessions
    submissions
  end
end
