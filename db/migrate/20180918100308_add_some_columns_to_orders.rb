class AddSomeColumnsToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :extras, :jsonb, default: {}
    add_index :orders, :extras, using: :gin
  end
end
