class RemoveReceiverIdFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :receiver_id, :uuid
    remove_column :orders, :giver_ids, default: []
  end
end
