class AddScheduleObjectToTrips < ActiveRecord::Migration[5.1]
  def change
    remove_column :trips, :schedule_at, :datetime
  end
end
