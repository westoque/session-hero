# == Schema Information
#
# Table name: event_speakers
#
#  id             :integer          not null, primary key
#  bio            :text
#  company        :string
#  custom         :json
#  email          :string
#  linkedin       :string
#  name           :string           not null
#  position       :integer          default(0)
#  public_visible :boolean          default(TRUE), not null
#  returning      :boolean          default(FALSE), not null
#  status         :string           default("invited"), not null
#  title          :string
#  travel_notes   :text
#  twitter        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  event_id       :integer          not null
#  user_id        :integer
#
# Indexes
#
#  index_event_speakers_on_event_id            (event_id)
#  index_event_speakers_on_event_id_and_email  (event_id,email)
#  index_event_speakers_on_user_id             (user_id)
#
# Foreign Keys
#
#  event_id  (event_id => events.id)
#  user_id   (user_id => users.id)
#
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

  # Every speaker added to an event flows into the organizers' cross-event
  # Speaker CRM, so the CRM stays the master contact database.
  after_commit :sync_to_crm, on: %i[create update]

  def initials
    name.to_s.split.map(&:first).first(2).join.upcase.presence || "?"
  end

  # Sessions this speaker actually presents (accepted/scheduled), for portal + public.
  def sessions
    submissions
  end

  # Upsert a CRM contact for each organizer of this event, matched by email
  # (or name when there's no email). Only fills blank fields so organizer edits
  # in the CRM aren't clobbered by later roster edits.
  def sync_to_crm
    event.organizers.each do |owner|
      contact =
        if email.present?
          owner.contacts.where("lower(email) = ?", email.downcase).first ||
            owner.contacts.new(email: email)
        else
          owner.contacts.where("lower(name) = ?", name.to_s.downcase).first ||
            owner.contacts.new
        end
      contact.name       = name if contact.name.blank?
      contact.email      = email if contact.email.blank? && email.present?
      contact.company    = company if contact.company.blank? && company.present?
      contact.job_title  = title if contact.job_title.blank? && title.present?
      contact.bio        = bio if contact.bio.blank? && bio.present?
      contact.save if contact.new_record? || contact.changed?
    end
  rescue => e
    Rails.logger.warn("EventSpeaker#sync_to_crm failed for ##{id}: #{e.message}")
  end
end
