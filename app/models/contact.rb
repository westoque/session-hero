# == Schema Information
#
# Table name: contacts
#
#  id                 :integer          not null, primary key
#  bio                :text
#  company            :string
#  custom             :json
#  email              :string
#  job_title          :string
#  name               :string           not null
#  pipeline_rationale :text
#  pipeline_score     :integer
#  pipeline_stage     :string
#  position           :integer          default(0)
#  speaker_type       :string
#  tags               :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  owner_id           :integer          not null
#
# Indexes
#
#  index_contacts_on_owner_id            (owner_id)
#  index_contacts_on_owner_id_and_email  (owner_id,email)
#
# Foreign Keys
#
#  owner_id  (owner_id => users.id)
#
class Contact < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :contact_notes, dependent: :destroy
  default_scope { order(:position, :name) }

  STAGES = %w[Identified Contacted Interested Confirmed Declined].freeze
  validates :name, presence: true

  def tag_list = Array(tags)
  def enrolled? = pipeline_stage.present?
  def initials = name.to_s.split.map(&:first).first(2).join.upcase.presence || "?"
end
