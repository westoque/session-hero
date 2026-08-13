# == Schema Information
#
# Table name: contact_notes
#
#  id          :integer          not null, primary key
#  author_name :string
#  body        :text
#  kind        :string           default("note")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  contact_id  :integer          not null
#  user_id     :integer
#
# Indexes
#
#  index_contact_notes_on_contact_id  (contact_id)
#  index_contact_notes_on_user_id     (user_id)
#
# Foreign Keys
#
#  contact_id  (contact_id => contacts.id)
#  user_id     (user_id => users.id)
#
class ContactNote < ApplicationRecord
  belongs_to :contact
  belongs_to :user, optional: true
  default_scope { order(created_at: :desc) }
  def display_author = author_name.presence || user&.display_name || "Someone"
end
