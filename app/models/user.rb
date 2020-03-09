# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :group_users, dependent: :destroy
  has_many :group, through: :group_users
  accepts_nested_attributes_for :group_users
  has_many :answers
  has_many :events, through: :answers # :nullifyの方がよいか？
  has_many :transactions, dependent: :destroy # :nullifyの方がよいか？
  validates :name, presence: true, length: { maximum: 100 }
  validates :definitive_registration, inclusion: { in: [true, false] }

  def self.import!(file, group, pass)
    added_users = []
    transaction do
      CSV.foreach(file.path, headers: true, skip_blanks: true, encoding: 'CP932:UTF-8') do |row|
        name = row['名前']
        email = row['メールアドレス']
        user = User.new(name: name, email: email, password: pass,
                        definitive_registration: false)
        user.skip_confirmation!
        user.save!
        GroupUser.create!(group_id: group.id, user_id: user.id, role: GroupUser.roles[:general])
        added_users << user
      end
    end
    added_users
    # 例外処理は今度書く
  end

  # あるグループの幹事たち
  def self.executives(group)
    executives = []
    GroupUser.where(group_id: group.id, role: GroupUser.roles[:executive]).each do |relationship|
      executives << User.find(relationship.user_id)
    end
    executives
  end

  # あるグループの一般ピーポー
  def self.generals(group)
    generals = []
    GroupUser.where(group_id: group.id, role: GroupUser.roles[:general]).each do |relationship|
      generals << User.find(relationship.user_id)
    end
    generals
  end

  # あるグループのメンバー
  def self.members(group)
    members = []
    GroupUser.where(group_id: group.id).each do |relationship|
      members << User.find(relationship.user_id)
    end
    members
  end
end
