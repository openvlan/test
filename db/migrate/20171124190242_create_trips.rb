class CreateTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :trips, id: :uuid do |t|
      t.uuid :shipper_id, index: true

      t.string :status
      t.string :comments

      t.decimal :amount, precision: 12, scale: 4, default: 0

      t.datetime :schedule_at

      t.jsonb :pickups, null: false, default: []
      t.jsonb :dropoffs, null: false, default: []

      t.string :gateway
      t.string :gateway_id
      t.jsonb :gateway_data, null: true, default: {}

      t.timestamps
    end
    add_index :trips, :pickups, using: :gin
    add_index :trips, :dropoffs, using: :gin
    add_index :trips, :gateway_data, using: :gin

    add_foreign_key :trips, :shippers
    add_foreign_key :deliveries, :trips
  end
end
