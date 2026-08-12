# == Schema Information
#
# Table name: submissions
#
#  id                 :integer          not null, primary key
#  abstract           :text
#  status             :string           default("submitted"), not null
#  talk_format        :string
#  title              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  event_id           :integer          not null
#  speaker_profile_id :integer
#  user_id            :integer          not null
#
# Indexes
#
#  index_submissions_on_event_id            (event_id)
#  index_submissions_on_speaker_profile_id  (speaker_profile_id)
#  index_submissions_on_user_id             (user_id)
#
# Foreign Keys
#
#  event_id            (event_id => events.id)
#  speaker_profile_id  (speaker_profile_id => speaker_profiles.id)
#  user_id             (user_id => users.id)
#
class Submission < ApplicationRecord
  belongs_to :event
  belongs_to :user
  belongs_to :speaker_profile, optional: true

  # Virtual fields used only by the public CFP form (not columns) so simple_form's
  # f.input can render them. The controller reads them to find-or-create the user.
  attr_accessor :speaker_name, :contact_email

  enum :status, {
    draft: "draft", submitted: "submitted", under_review: "under_review",
    accepted: "accepted", rejected: "rejected", waitlisted: "waitlisted"
  }

  validates :title, presence: true
  validates :abstract, presence: true
end
