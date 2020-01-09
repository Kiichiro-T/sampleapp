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
      CSV.foreach(file.path, headers: true, skip_blanks: true) do |row|
        name = row['name']
        User.create!(name: name, email: "#{name}@test.com", password: "password", group_id: group.id)
      end
    end
end
