class ChangeGiverIdToAnArrayInOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :giver_ids, :text, default: [], array:true

    orders = Order.all
    orders.each do |o|
      o.giver_ids = o.giver_id.split
      o.save
    end

    remove_column :orders, :giver_id
  end
end
