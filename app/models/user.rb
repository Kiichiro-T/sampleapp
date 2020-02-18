class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :group, through: :group_users
  has_many :group_users
  accepts_nested_attributes_for :group_users
  has_many :events, dependent: :destroy
  has_many :transactions, dependent: :destroy
  validates :name, presence: true, length: { maximum: 100 }
  validates :definitive_registration, inclusion: {in: [true, false]}

    def self.import!(file, group, pass)
      added_users = []
      self.transaction do
        CSV.foreach(file.path, headers: true, skip_blanks: true, encoding: "CP932:UTF-8") do |row|
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
end
