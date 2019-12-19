class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :user, foreign_key: true
      t.references :event, foreign_key: true
      t.string :debtor, null: false
      t.datetime :deadline
      t.integer :debt, null: false

      t.timestamps
    end
  end
end
