class RemoveExtrasFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :extras, :jsonb, default: {}
  end
end
