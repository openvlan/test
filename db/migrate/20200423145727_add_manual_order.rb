class AddManualOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :manual_order, :boolean, default: false
  end
end
