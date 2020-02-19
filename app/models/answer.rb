class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :event
  enum status: {
    unanswered: 10, # 未回答
    attending: 20, # 出席
    absent: 30 # 欠席
  }
  validates :status, presence: true
  validates :user_id, presence: true
  validates :event_id, presence: true
  validates_uniqueness_of :event_id, scope: :user_id
end
