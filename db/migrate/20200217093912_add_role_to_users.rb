class AddRoleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :role, :integer, null: false, default: 10
  end
end
