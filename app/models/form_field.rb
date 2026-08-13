class FormField < ApplicationRecord
  belongs_to :submission_form
  belongs_to :conditional_field, class_name: "FormField", optional: true
  default_scope { order(:position, :id) }

  FIELD_TYPES = %w[short_text long_text dropdown checkbox number].freeze
  validates :label, presence: true
  validates :field_type, inclusion: { in: FIELD_TYPES }

  def option_list = Array(options)
  def choice? = %w[dropdown checkbox].include?(field_type)
end
