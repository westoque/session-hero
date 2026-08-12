# == Schema Information
#
# Table name: speaker_profiles
#
#  id         :integer          not null, primary key
#  bio        :text
#  company    :string
#  headline   :string
#  job_title  :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_speaker_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class SpeakerProfile < ApplicationRecord
  belongs_to :user
  has_many :submissions, dependent: :nullify

  validates :name, presence: true
end
