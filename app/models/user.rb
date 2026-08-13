# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one  :speaker_profile, dependent: :destroy
  has_many :event_memberships, dependent: :destroy
  has_many :events, through: :event_memberships
  has_many :created_events, class_name: "Event", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :creator
  has_many :submissions, dependent: :destroy
  has_many :contacts, foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_many :segments, foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_many :review_assignments, dependent: :destroy
  has_many :reviews, dependent: :destroy

  # Speaker portal identity: roster entries across all events keyed to this email.
  def event_speakers = EventSpeaker.where("lower(email) = ?", email.to_s.downcase)
  def portal_events  = Event.where(id: event_speakers.select(:event_id))
  def reviewer_of?(event) = event_memberships.exists?(event: event, role: :reviewer)

  # Events where this user wears a given hat. Role lives on the membership,
  # not the user, so the same person can organize one event and speak at another.
  def organizing_events = events.merge(EventMembership.organizer)
  def speaking_events   = events.merge(EventMembership.speaker)

  def organizer_of?(event) = event_memberships.exists?(event: event, role: :organizer)
  def speaker_of?(event)   = event_memberships.exists?(event: event, role: :speaker)

  def full_name = [first_name, last_name].filter_map(&:presence).join(" ").presence
  def display_name = full_name || speaker_profile&.name.presence || email
end
