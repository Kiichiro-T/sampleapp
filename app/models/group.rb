class Group < ApplicationRecord
  has_many :users
  has_many :events, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :leader, class_name: 'User', foreign_key: 'leader_id'
  validates :name, presnce: true, length: { maximum: 100}
  validates :leader_id, presnce: true
  validates :email, presnce: true, uniqueness: true
end
