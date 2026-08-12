# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
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

  # Events where this user wears a given hat. Role lives on the membership,
  # not the user, so the same person can organize one event and speak at another.
  def organizing_events = events.merge(EventMembership.organizer)
  def speaking_events   = events.merge(EventMembership.speaker)

  def organizer_of?(event) = event_memberships.exists?(event: event, role: :organizer)
  def speaker_of?(event)   = event_memberships.exists?(event: event, role: :speaker)

  def display_name = speaker_profile&.name.presence || email
end
