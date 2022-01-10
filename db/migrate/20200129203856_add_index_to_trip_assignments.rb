class AddIndexToTripAssignments < ActiveRecord::Migration[5.1]
  def change
    add_index :trip_assignments, :state
    add_index :trip_assignments, :closed_at, where: "(closed_at is null)"
  end
end
