class AddNeedsCoolingForOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :needs_cooling, :boolean, default: false
  end
end
