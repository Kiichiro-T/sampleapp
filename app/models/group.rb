class Group < ApplicationRecord
  has_many :users
  has_many :events, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :leader, class_name: 'User', foreign_key: 'leader_id'
  validates :name, presence: true, length: { maximum: 100 }
  validates :leader_id, presence: true
  # email
  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX } # 一位である必要はない
  # group_number
  VALID_GRPUP_NUMBER_REGEX = /\A(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]\w{6,25}\z/
  validates :group_number, presence: true, uniqueness: true,
                           format: { with: VALID_GRPUP_NUMBER_REGEX },
                           length: { in: 6..25 }
  # emailの認証とバリデーションを後で追加する
end
