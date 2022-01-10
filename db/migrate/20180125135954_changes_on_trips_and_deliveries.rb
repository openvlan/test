class ChangesOnTripsAndDeliveries < ActiveRecord::Migration[5.1]
   def change
    remove_index :trips, :pickups
    remove_index :trips, :dropoffs

    remove_column :trips, :pickups, :jsonb, null: true, default: {}
    remove_column :trips, :dropoffs, :jsonb, null: true, default: {}

    add_column :trips, :steps, :jsonb, null: false, default: []

    add_column :deliveries, :pickup, :jsonb, null: true, default: {}
    add_column :deliveries, :dropoff, :jsonb, null: true, default: {}
    add_column :deliveries, :extras, :jsonb, null: true, default: {}

    add_index :trips, :steps, using: :gin
    add_index :deliveries, :pickup, using: :gin
    add_index :deliveries, :dropoff, using: :gin
    add_index :deliveries, :extras, using: :gin
  end
end
