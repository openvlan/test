class AddDevicesToShippers < ActiveRecord::Migration[5.1]
  def change
    add_column :shippers, :devices, :jsonb, default: {}
    add_index :shippers, :devices, using: :gin
  end
end
