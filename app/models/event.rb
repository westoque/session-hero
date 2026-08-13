# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  agenda_published :boolean          default(FALSE), not null
#  cfp_closes_at    :datetime
#  cfp_opens_at     :datetime
#  description      :text
#  ends_on          :date
#  event_type       :string           default("Conference")
#  location         :string
#  name             :string
#  session_formats  :json
#  slug             :string
#  starts_on        :date
#  status           :string           default("draft"), not null
#  tagline          :string
#  theme            :text
#  timezone         :string           default("America/Los_Angeles")
#  website_url      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :integer
#
# Indexes
#
#  index_events_on_created_by_id  (created_by_id)
#  index_events_on_slug           (slug) UNIQUE
#
# Foreign Keys
#
#  created_by_id  (created_by_id => users.id)
#
class Event < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, optional: true, inverse_of: :created_events

  has_many :event_memberships, dependent: :destroy
  has_many :members, through: :event_memberships, source: :user
  has_many :submissions, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :event_speakers, dependent: :destroy
  has_many :submission_forms, dependent: :destroy
  has_many :review_rounds, dependent: :destroy
  has_many :portal_tasks, dependent: :destroy
  has_many :email_templates, dependent: :destroy
  has_many :communication_logs, dependent: :destroy

  has_one_attached :logo
  has_one_attached :background

  enum :status, { draft: "draft", published: "published", archived: "archived" }

  before_validation :assign_slug, on: :create
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  DEFAULT_FORMATS = ["Keynote (45 min)", "Talk (30 min)", "Lightning Talk (10 min)",
                     "Workshop (120 min)", "Panel (45 min)"].freeze

  # Pretty, shareable URLs: /events/ai-event-for-2026
  def to_param = slug

  def organizers = members.merge(EventMembership.organizer)
  def speakers   = members.merge(EventMembership.speaker)
  def reviewers  = members.merge(EventMembership.reviewer)

  def formats
    Array(session_formats).presence || DEFAULT_FORMATS
  end

  # The canonical CFP form for this event (auto-provisioned on demand).
  def cfp_form
    submission_forms.first || build_default_form
  end

  # Sessions = accepted submissions, i.e. the ones that reach the agenda/public.
  def sessions = submissions.where(status: "accepted")
  def scheduled_sessions = sessions.where.not(starts_at: nil).order(:starts_at)
  def public_sessions
    sessions.where(public_visible: true, content_status: "approved")
  end

  def public_speakers
    event_speakers.public_visible.select { |s| s.submissions.any? { |sub| sub.accepted? } }
  end

  def date_range
    return nil unless starts_on
    ends_on && ends_on != starts_on ? "#{starts_on.strftime('%b %-d')} – #{ends_on.strftime('%b %-d, %Y')}" : starts_on.strftime("%B %-d, %Y")
  end

  # Distinct event days spanned by the agenda (for day tabs).
  def agenda_days
    return [] unless starts_on
    last = ends_on || starts_on
    (starts_on..last).to_a
  end

  def cfp_open?
    form = submission_forms.first
    return form.open? if form&.closes_at.present?
    return true if cfp_opens_at.blank? && cfp_closes_at.blank?
    now = Time.current
    (cfp_opens_at.blank? || cfp_opens_at <= now) && (cfp_closes_at.blank? || now <= cfp_closes_at)
  end

  def cfp_deadline = submission_forms.first&.closes_at || cfp_closes_at

  private

  def build_default_form
    submission_forms.create!(
      name: "Session Submission Form",
      title: "Submit a session to #{name}",
      welcome_message: "We'd love to hear your proposal. Tell us about your session.",
      confirmation_message: "Thanks! Your proposal has been received.",
      closes_at: cfp_closes_at
    )
  end

  def assign_slug
    return if slug.present?
    base = name.to_s.parameterize.presence || "event"
    candidate = base
    n = 1
    while Event.where.not(id: id).exists?(slug: candidate)
      n += 1
      candidate = "#{base}-#{n}"
    end
    self.slug = candidate
  end
end
