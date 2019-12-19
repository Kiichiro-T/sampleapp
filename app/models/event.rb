class Event < ApplicationRecord
  belongs_to :user
  has_many  :transactions
  validates :name, presence: true, length: { maximum: 1024 }
  validates :user_id, presence: true
end
