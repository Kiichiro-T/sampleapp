class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :event
  validates :user_id, presence: true
  validates :event_id, presence: true
  validates :debtor, presence: true
  validate :deadline_before_today
  validates :debt, presence: true
  validates :debt, numericality: { only_integer: true}
  validates :debt, numericality: { greater_than_or_equal_to: 0 }

  private

    def deadline_before_today
      errors.add(:start_date, "は今日以降のものを選択してください") if deadline.nil? || deadline < Date.today.to_datetime
    end
end
