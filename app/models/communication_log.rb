# == Schema Information
#
# Table name: communication_logs
#
#  id         :integer          not null, primary key
#  body       :text
#  kind       :string           default("email")
#  recipients :json
#  sent_at    :datetime
#  subject    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :integer
#  user_id    :integer
#
# Indexes
#
#  index_communication_logs_on_event_id  (event_id)
#  index_communication_logs_on_user_id   (user_id)
#
# Foreign Keys
#
#  event_id  (event_id => events.id)
#  user_id   (user_id => users.id)
#
class CommunicationLog < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :user, optional: true
  default_scope { order(sent_at: :desc, created_at: :desc) }
  def recipient_list = Array(recipients)
  def recipient_count = recipient_list.size
end
