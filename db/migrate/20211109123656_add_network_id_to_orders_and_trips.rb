class AddNetworkIdToOrdersAndTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :network_id, :integer
    add_column :trips, :network_id, :integer
  end
end
