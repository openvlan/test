class AddWithDeliveryToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :with_delivery, :boolean
  end
end
