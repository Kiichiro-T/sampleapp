class Group < ApplicationRecord
  has_many :users
  has_many :events, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :leader, class_name: 'User', foreign_key: 'leader_id'
  validates :name, presence: true, length: { maximum: 100 }
  validates :leader_id, presence: true
  validates :email, presence: true, uniqueness: true
  # emailの認証とバリデーションを後で追加する
end
