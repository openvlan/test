class AddNetworkIdIndexesInTripsAndOrders < ActiveRecord::Migration[5.2]
  def change
    add_index :trips, :network_id
    add_index :orders, :network_id
  end
end
