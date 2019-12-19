class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.datetime :deadline
      t.integer :debt,    null: false
      t.integer :payment, null: false

      t.timestamps
    end
  end
end
