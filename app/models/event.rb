class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many  :transactions, dependent: :destroy
  validates :name, presence: true, length: { maximum: 128 }
  validates :start_date, presence: true
  validate  :start_date_not_before_today
  validates :end_date, presence: true
  validate  :end_date_not_before_start_date
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :description, length: { maximum: 1024 }
  validate  :pay_deadline_not_before_today
  validates :user_id, presence: true
  validates :group_id, presence: true

  private

    # 開始日は今日以降の日付
    def start_date_not_before_today
      errors.add(:start_date, "は今日以降のものを選択してください") if start_date.nil? || self.start_date < Date.today.to_datetime
    end

    # 終了日は開始日以降の日付
    # 現状は今日以降の日付となってしまっている
    def end_date_not_before_start_date
      errors.add(:end_date, "は開始日以降のものを選択してください") if end_date.nil? || self.end_date < Date.today.to_datetime
    end
    
    # 支払い締め切りは今日以降の日付
    def pay_deadline_not_before_today
      return if pay_deadline.nil?
      errors.add(:pay_deadline, "は今日以降のものを選択してください") if pay_deadline < Date.today.to_datetime
    end
end
