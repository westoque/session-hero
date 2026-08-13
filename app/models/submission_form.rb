class SubmissionForm < ApplicationRecord
  belongs_to :event
  has_many :form_fields, dependent: :destroy
  has_many :submissions, dependent: :nullify
  default_scope { order(:position, :id) }

  def open?
    closes_at.blank? || Time.current <= closes_at
  end

  def closed? = !open?
end
