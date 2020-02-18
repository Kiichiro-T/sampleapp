class Transaction < ApplicationRecord
  attribute :url_token, :string, default: SecureRandom.hex(10)
  belongs_to :creditor, class_name: 'User', foreign_key: 'creditor_id'
  belongs_to :debtor, class_name: 'User', foreign_key: 'debtor_id'
  belongs_to :event
  belongs_to :group
  validates :debtor_id, presence: true
  validates :creditor_id, presence: true
  validates :event_id, presence: true
  validates :group_id, presence: true
  validate  :deadline_before_today
  validates :debt, presence: true
  validates :debt, numericality: { only_integer: true}
  validates :debt, numericality: { greater_than_or_equal_to: 0 }
  validates :payment, presence: true
  validates :payment, numericality: { only_integer: true}
  validates :payment, numericality: { greater_than_or_equal_to: 0 }
  validates :type, presence: true
  validates :url_token, presence: true, uniqueness: true

  def to_param
    url_token
  end

  private

    def deadline_before_today
      errors.add(:deadline, "は今日以降のものを選択してください") if deadline.nil? || deadline < Date.today.to_datetime
    end

    # def payment_is_equal_or_smaller_than_debt
    #   errors.add(:payment, "は", :debt, "以下にしてください") if payment <= debt
    # end
end
