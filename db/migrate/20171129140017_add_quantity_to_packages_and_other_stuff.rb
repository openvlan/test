class AddQuantityToPackagesAndOtherStuff < ActiveRecord::Migration[5.1]
  def change
    change_column :packages, :cooling, :boolean, default: false
    add_column :packages, :quantity, :integer, null: true, default: 1
    add_column :packages, :fragile, :boolean, default: false

    add_column :addresses, :lookup, :string
    add_column :addresses, :gateway, :string
    add_column :addresses, :gateway_id, :string
    add_column :addresses, :gateway_data, :jsonb, null: true, default: {}

    add_column :deliveries, :gateway, :string
    add_column :deliveries, :gateway_id, :string
    add_column :deliveries, :gateway_data, :jsonb, null: true, default: {}

    add_index :addresses, :gateway_data, using: :gin
    add_index :deliveries, :gateway_data, using: :gin
  end
end
