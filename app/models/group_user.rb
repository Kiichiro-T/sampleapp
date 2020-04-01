# frozen_string_literal: true

class GroupUser < ApplicationRecord
  belongs_to :group, dependent: :destroy
  belongs_to :user, dependent: :destroy
  enum role: {
    general: 10,  # 一般人
    executive: 90 # 幹部
  }
  validates :group_id, presence: true
  validates :group_id, uniqueness:{ scope: [:user_id] }
  validates :user_id, presence: true
  validates :role, presence: true

  def self.new_group(group, user)
    GroupUser.create!(
      group_id: group.id,
      user_id: user.id,
      role: GroupUser.roles[:executive]
    )
  end

  def self.general_relationship(group:, user:)
    GroupUser.find_by(group_id: group.id, user_id: user.id, role: GroupUser.roles[:general])
  end

  def self.executive_relationship(group:, user:)
    GroupUser.find_by(group_id: group.id, user_id: user.id, role: GroupUser.roles[:executive])
  end
end
