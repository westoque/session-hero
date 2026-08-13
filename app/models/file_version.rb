class FileVersion < ApplicationRecord
  belongs_to :deliverable
  has_one_attached :file
  default_scope { order(:version_number) }

  def filename = file.attached? ? file.filename.to_s : "file"
  def latest? = deliverable.file_versions.maximum(:version_number) == version_number
end
