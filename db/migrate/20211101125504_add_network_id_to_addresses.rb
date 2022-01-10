class AddNetworkIdToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :network_id, :integer, index: true
  end
end
