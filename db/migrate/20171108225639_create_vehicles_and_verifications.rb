class CreateVehiclesAndVerifications < ActiveRecord::Migration[5.1]
  def change
    remove_index :shippers, :vehicles
    remove_column :shippers, :vehicles, :jsonb, null: true, default: {}

    create_table :vehicles, id: :uuid do |t|
      t.uuid :shipper_id, index: true

      t.string :model, null: false
      t.string :brand
      t.integer :year

      t.jsonb :extras, null: true, default: {}

      t.timestamps
    end
    add_index  :vehicles, :extras, using: :gin
    add_foreign_key :vehicles, :shippers

    create_table :verifications do |t|
      t.references :verificable, polymorphic: true, index: true, type: :uuid

      t.jsonb :data, null: true, default: {}

      t.datetime :verified_at
      t.uuid :verified_by

      t.boolean :expire
      t.datetime :expire_at

      t.timestamps
    end
    add_index  :verifications, :data, using: :gin
  end
end
