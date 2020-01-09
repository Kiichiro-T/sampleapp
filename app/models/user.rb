class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :events, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :group, optional: true
  # has_manyもある？とりあえず一旦は一つのグループに所属している方針で設計する
  validates :name, presence: true, length: { maximum: 100 }
  validates :group_id, presence: true, allow_nil: true

    def self.import(file, group)
      added_user_count = 0
      CSV.foreach(file.path, headers: true, skip_blanks: true) do |row|
        name = row['name']
        user = User.new(name: name, email: "#{name}@test.com", password: "password", group_id: group.id)
        if user.valid?
          user.save!
          added_user_count += 1
        end
      end
      added_user_count
    end
end
