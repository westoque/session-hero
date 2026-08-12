# == Schema Information
#
# Table name: events
#
#  id            :integer          not null, primary key
#  cfp_closes_at :datetime
#  cfp_opens_at  :datetime
#  description   :text
#  ends_on       :date
#  name          :string
#  slug          :string
#  starts_on     :date
#  status        :string           default("draft"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer
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

  enum :status, { draft: "draft", published: "published", archived: "archived" }

  before_validation :assign_slug, on: :create
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Pretty, shareable URLs: /events/ai-event-for-2026
  def to_param = slug

  def organizers = members.merge(EventMembership.organizer)
  def speakers   = members.merge(EventMembership.speaker)

  def cfp_open?
    return true if cfp_opens_at.blank? && cfp_closes_at.blank?
    now = Time.current
    (cfp_opens_at.blank? || cfp_opens_at <= now) && (cfp_closes_at.blank? || now <= cfp_closes_at)
  end

  private

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
