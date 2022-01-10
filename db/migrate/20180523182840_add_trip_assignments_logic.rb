class AddTripAssignmentsLogic < ActiveRecord::Migration[5.1]
  def up
    create_table :trip_assignments do |t|
      t.string  :state

      t.uuid  :trip_id, index: true
      t.uuid  :shipper_id, index: true

      t.datetime :created_at

      t.jsonb :notification_payload, default: {}
      t.datetime :notified_at

      t.datetime :closed_at
    end
    add_index :trip_assignments, [:trip_id, :shipper_id]
    add_index :trip_assignments, :notification_payload, using: :gin
  end

  def down
    drop_table :trip_assignments
  end

end
