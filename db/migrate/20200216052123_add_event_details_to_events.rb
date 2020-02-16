class AddEventDetailsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :start_date, :datetime
    add_column :events, :end_date, :datetime
    add_column :events, :amount, :integer
    add_column :events, :description, :text
    add_column :events, :pay_deadline, :datetime
  end
end
