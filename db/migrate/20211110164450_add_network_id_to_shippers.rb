class AddNetworkIdToShippers < ActiveRecord::Migration[5.2]
  def change
    add_column :shippers, :network_id, :integer
    add_index :shippers, :network_id
  end
end
