class EmailTemplate < ApplicationRecord
  belongs_to :event, optional: true
  default_scope { order(:name) }
  validates :name, presence: true

  # Resolve {merge_field} / {{merge_field}} tokens against a context hash.
  def self.render(text, ctx)
    text.to_s.gsub(/\{\{?\s*(\w+)\s*\}?\}/) { ctx[$1.to_sym] || ctx[$1] || "" }
  end

  def render_subject(ctx) = self.class.render(subject, ctx)
  def render_body(ctx)    = self.class.render(body, ctx)
end
