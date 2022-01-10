class AddTripIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :start_datetime, :datetime

    change_column_default :trips, :status, from: nil, to: "0" 
  end
end
