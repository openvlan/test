class RemoveNetworksReferences < ActiveRecord::Migration[5.2]
  def change
    remove_column :milestones, :network_id
    remove_column :orders, :network_id
    remove_column :shippers, :network_id
    remove_column :trips, :network_id
    remove_column :vehicles, :network_id
    remove_column :verifications, :network_id
  end
end
