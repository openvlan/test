class CreateTripStepPhoto < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_step_photos do |t|
      t.references :trip, type: :uuid, foreign_key: true, null: false
      t.references :shipper, type: :uuid, foreign_key: true, null: false
      t.integer :step_index, null: false
      t.geography :gps_coordinates, limit: {srid: 4326, type: "st_point", geographic: true}, null: true
      t.timestamps
    end
  end
end
