class Room < ApplicationRecord
  belongs_to :event
  has_many :submissions, dependent: :nullify
  validates :name, presence: true
  default_scope { order(:position, :id) }
end
