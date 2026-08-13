class CommunicationLog < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :user, optional: true
  default_scope { order(sent_at: :desc, created_at: :desc) }
  def recipient_list = Array(recipients)
  def recipient_count = recipient_list.size
end
