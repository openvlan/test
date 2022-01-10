class AddMarketplaceOrderIdUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :orders, :marketplace_order_id, unique: true
  end
end
