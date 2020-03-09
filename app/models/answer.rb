# frozen_string_literal: true

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

  def self.divide_answers_in_three(event)
    answers = event.answers
    {
      attending: answers.where(status: Answer.statuses[:attending]),
      absent: answers.where(status: Answer.statuses[:absent]),
      unanswered: answers.where(status: Answer.statuses[:unanswered])
    }
  end

  def self.new_answer_when_create_new_event(user, event)
    Answer.create!(
      status: Answer.statuses[:unanswered],
      user_id: user.id,
      event_id: event.id
    )
  end
end
