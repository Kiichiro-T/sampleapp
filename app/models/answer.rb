class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :event
  validates :status, presence: true
  validates :user_id, presence: true
  validates :event_id, presence: true
  validates_uniqueness_of :event_id, scope: :user_id
end
