class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :user, foreign_key: true
      t.references :event, foreign_key: true
      t.string :debtor
      t.datetime :deadline
      t.integer :debt
      t.boolean :repayment, default: false, null: false

      t.timestamps
    end
  end
end
