class AddPaidToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :paid, :boolean, default: false, null: false
  end
end
