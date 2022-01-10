class AddNetworkIdToTables < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :network_id, :string
    add_column :bank_accounts, :network_id, :string
    add_column :milestones, :network_id, :string
    add_column :packages, :network_id, :string
    add_column :payments, :network_id, :string
    add_column :shippers, :network_id, :string
    add_column :trips, :network_id, :string
    add_column :trip_assignments, :network_id, :string
    add_column :vehicles, :network_id, :string
    add_column :verifications, :network_id, :string
    add_index :orders, :network_id
    add_index :bank_accounts, :network_id
    add_index :milestones, :network_id
    add_index :packages, :network_id
    add_index :payments, :network_id
    add_index :shippers, :network_id
    add_index :trips, :network_id
    add_index :trip_assignments, :network_id
    add_index :vehicles, :network_id
    add_index :verifications, :network_id
  end
end
