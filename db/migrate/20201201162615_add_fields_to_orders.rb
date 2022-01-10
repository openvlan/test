class AddFieldsToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :delivery_cost, :decimal, precision: 12, scale: 2, default: 0
    add_column :orders, :delivery_distance, :decimal, precision: 12, scale: 2, default: 0
    add_column :orders, :weight, :decimal, precision: 8, scale: 2, default: 0
    add_column :orders, :warehouse_address_id, :string
    add_column :orders, :delivery_location_id, :string
    add_column :orders, :marketplace_order_id, :string
  end
end
