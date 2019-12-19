class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many  :transactions, dependent: :destroy
  validates :name, presence: true, length: { maximum: 1024 }
  validates :user_id, presence: true
  validates :group_id, presence: true
end
