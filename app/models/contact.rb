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
