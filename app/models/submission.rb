# == Schema Information
#
# Table name: submissions
#
#  id                 :integer          not null, primary key
#  abstract           :text
#  answers            :json
#  audience_level     :string
#  content_status     :string           default("draft"), not null
#  ends_at            :datetime
#  key_takeaway       :string
#  position           :integer          default(0)
#  public_visible     :boolean          default(TRUE), not null
#  starts_at          :datetime
#  status             :string           default("submitted"), not null
#  talk_format        :string
#  title              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  event_id           :integer          not null
#  event_speaker_id   :integer
#  room_id            :integer
#  speaker_profile_id :integer
#  submission_form_id :integer
#  track_id           :integer
#  user_id            :integer          not null
#
# Indexes
#
#  index_submissions_on_event_id            (event_id)
#  index_submissions_on_event_speaker_id    (event_speaker_id)
#  index_submissions_on_room_id             (room_id)
#  index_submissions_on_speaker_profile_id  (speaker_profile_id)
#  index_submissions_on_submission_form_id  (submission_form_id)
#  index_submissions_on_track_id            (track_id)
#  index_submissions_on_user_id             (user_id)
#
# Foreign Keys
#
#  event_id            (event_id => events.id)
#  event_speaker_id    (event_speaker_id => event_speakers.id)
#  room_id             (room_id => rooms.id)
#  speaker_profile_id  (speaker_profile_id => speaker_profiles.id)
#  submission_form_id  (submission_form_id => submission_forms.id)
#  track_id            (track_id => tracks.id)
#  user_id             (user_id => users.id)
#
class Submission < ApplicationRecord
  belongs_to :event
  belongs_to :user
  belongs_to :speaker_profile, optional: true
  belongs_to :track, optional: true
  belongs_to :room, optional: true
  belongs_to :event_speaker, optional: true
  belongs_to :submission_form, optional: true

  has_many :session_participants, dependent: :destroy
  has_many :participants, through: :session_participants, source: :event_speaker
  has_many :reviews, dependent: :destroy
  has_many :review_assignments, dependent: :destroy
  has_many :deliverables, dependent: :destroy
  has_many :submission_versions, dependent: :destroy

  # Virtual fields used only by the public CFP form (not columns) so simple_form's
  # f.input can render them. The controller reads them to find-or-create the user.
  attr_accessor :speaker_name, :contact_email

  enum :status, {
    draft: "draft", submitted: "submitted", under_review: "under_review",
    accepted: "accepted", rejected: "rejected", waitlisted: "waitlisted"
  }

  # Content/approval lifecycle for deliverables + public gating.
  CONTENT_STATUSES = %w[draft in_review approved].freeze

  validates :title, presence: true
  validates :abstract, presence: true, unless: :draft?

  # A submitter is a speaker: make sure they have a roster (EventSpeaker) record
  # linked to this session so their speaker portal recognizes them.
  after_commit :ensure_event_speaker!, on: %i[create update]

  scope :scheduled, -> { where.not(starts_at: nil) }

  def answers = super || {}
  def approved? = content_status == "approved"

  # Every speaker on this session (primary + co-speakers), in order.
  def speakers
    ep = participants.to_a
    ep = [event_speaker].compact if ep.empty?
    ep
  end

  def speaker_names = speakers.map(&:name).join(", ")
  def primary_speaker = participants.first || event_speaker

  def ends_at_or_default
    ends_at || (starts_at && starts_at + 30.minutes)
  end

  def time_range
    return nil unless starts_at
    "#{starts_at.strftime('%-I:%M %p')} – #{ends_at_or_default.strftime('%-I:%M %p')}"
  end

  # ── Conflict detection (for the agenda builder) ──────────────────
  def overlaps?(other)
    return false unless starts_at && other.starts_at
    a_end = ends_at_or_default; b_end = other.ends_at_or_default
    starts_at < b_end && other.starts_at < a_end
  end

  def room_conflicts
    return [] unless starts_at && room_id
    event.sessions.scheduled.where(room_id: room_id).where.not(id: id).select { |s| overlaps?(s) }
  end

  def speaker_conflicts
    return [] unless starts_at
    ids = speakers.map(&:id)
    return [] if ids.empty?
    event.sessions.scheduled.where.not(id: id).select do |s|
      overlaps?(s) && (s.speakers.map(&:id) & ids).any?
    end
  end

  def conflicts? = room_conflicts.any? || speaker_conflicts.any?

  # Link this submission's submitter to an EventSpeaker roster entry (find-or-
  # create by email). New CFP submissions already arrive linked; this backfills
  # manual/legacy ones so the submitter's speaker portal works.
  def ensure_event_speaker!
    return if event_speaker_id.present? || user.nil? || user.email.blank?
    sp = event.event_speakers.where("lower(email) = ?", user.email.downcase).first ||
         event.event_speakers.create!(name: user.display_name, email: user.email,
                                      status: accepted? ? "accepted" : "invited", user: user)
    update_columns(event_speaker_id: sp.id)
    session_participants.find_or_create_by!(event_speaker: sp) { |p| p.role = "Speaker" }
  end

  # Snapshot current title/abstract into history before an edit.
  def snapshot!(editor)
    submission_versions.create!(user: editor, editor_name: editor&.display_name,
                                title: title_was || title, abstract: abstract_was || abstract)
  end

  def latest_scores_by_criterion(round)
    round.review_criteria.map do |c|
      vals = reviews.where(review_round: round, status: "completed", coi: false)
                    .map { |r| r.scores.to_h[c.id.to_s] }.compact
      [c, vals]
    end
  end
end
