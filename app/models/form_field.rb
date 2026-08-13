# == Schema Information
#
# Table name: form_fields
#
#  id                   :integer          not null, primary key
#  conditional_value    :string
#  field_type           :string           default("short_text"), not null
#  help_text            :text
#  label                :string           not null
#  options              :json
#  position             :integer          default(0)
#  required             :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  conditional_field_id :bigint
#  submission_form_id   :integer          not null
#
# Indexes
#
#  index_form_fields_on_submission_form_id  (submission_form_id)
#
# Foreign Keys
#
#  submission_form_id  (submission_form_id => submission_forms.id)
#
class FormField < ApplicationRecord
  belongs_to :submission_form
  belongs_to :conditional_field, class_name: "FormField", optional: true
  attr_accessor :options_text
  default_scope { order(:position, :id) }

  FIELD_TYPES = %w[short_text long_text dropdown checkbox number].freeze
  validates :label, presence: true
  validates :field_type, inclusion: { in: FIELD_TYPES }

  def option_list = Array(options)
  def choice? = %w[dropdown checkbox].include?(field_type)
end
