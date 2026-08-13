# == Schema Information
#
# Table name: submission_forms
#
#  id                   :integer          not null, primary key
#  closes_at            :datetime
#  confirmation_message :text
#  name                 :string
#  position             :integer          default(0)
#  published            :boolean          default(TRUE), not null
#  title                :string
#  welcome_message      :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  event_id             :integer          not null
#
# Indexes
#
#  index_submission_forms_on_event_id  (event_id)
#
# Foreign Keys
#
#  event_id  (event_id => events.id)
#
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
