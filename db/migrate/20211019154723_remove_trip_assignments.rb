class RemoveTripAssignments < ActiveRecord::Migration[5.2]
  def change
    drop_table :trip_assignments
  end
end
