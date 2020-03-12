class AddDetailsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :gender, :boolean, null: false, comment: '性別'
    add_column :users, :grade, :integer, null: false, comment: '学年'
    add_column :users, :furigana, :string, null: false, index: true, comment: 'フリガナ'
  end
end
