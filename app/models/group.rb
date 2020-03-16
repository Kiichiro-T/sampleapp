# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  accepts_nested_attributes_for :group_users
  has_many :events, dependent: :destroy
  has_many :transactions, dependent: :destroy
  validates :name, presence: true, length: { maximum: 100 }
  # email
  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX } # 一意である必要はない
  # group_number
  VALID_GRPUP_NUMBER_REGEX = /\A(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]\w{6,25}\z/.freeze
  validates :group_number, presence: true, uniqueness: true,
                           format: { with: VALID_GRPUP_NUMBER_REGEX },
                           length: { in: 6..25 }

  def self.my_groups(user)
    groups = []
    GroupUser.where(user_id: user.id).each do |relationship|
      groups << Group.find(relationship.group_id)
    end
    groups
  end

  def self.is_my_group?(user:, group:)
    Group.my_groups(user).include?(group)
  end

  def self.my_own_group(user)
    relationship = GroupUser.find_by(user_id: user.id, role: GroupUser.roles[:executive])
    relationship.present? ? Group.find(relationship.group_id) : nil
  end
end
