class GroupUser < ApplicationRecord
  belongs_to :group, dependent: :destroy
  belongs_to :user, dependent: :destroy
  enum role: {
    member: 0,  # 一般人
    executive: 1 # 幹部
  }
  validates :group_id, presence: true
  validates :user_id, presence: true
end
