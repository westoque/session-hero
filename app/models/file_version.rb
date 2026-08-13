# == Schema Information
#
# Table name: file_versions
#
#  id             :integer          not null, primary key
#  version_number :integer          default(1)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deliverable_id :integer          not null
#
# Indexes
#
#  index_file_versions_on_deliverable_id  (deliverable_id)
#
# Foreign Keys
#
#  deliverable_id  (deliverable_id => deliverables.id)
#
class FileVersion < ApplicationRecord
  belongs_to :deliverable
  has_one_attached :file
  default_scope { order(:version_number) }

  def filename = file.attached? ? file.filename.to_s : "file"
  def latest? = deliverable.file_versions.maximum(:version_number) == version_number
end
