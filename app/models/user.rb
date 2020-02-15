class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_many :events, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :group, optional: true
  # has_manyもある？とりあえず一旦は一つのグループに所属している方針で設計する
  validates :name, presence: true, length: { maximum: 100 }
  validates :group_id, presence: true, allow_nil: true
  validates :definitive_registration, inclusion: {in: [true, false]}

    def self.import!(file, group, pass)
      added_user_count = 0
      self.transaction do
        CSV.foreach(file.path, headers: true, skip_blanks: true, encoding: "CP932:UTF-8") do |row|
          name = row['名前']
          email = row['メールアドレス']
          user = User.new(name: name, email: email, password: pass,
                            group_id: group.id, definitive_registration: false)
          user.skip_confirmation!
          user.save!
          added_user_count += 1
        end
      end
        added_user_count
        # 例外処理は今度書く
    end
end
