class AddRemovedToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :removed, :boolean, default: false
  end
end
