class AddDistanceOnTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :distance, :decimal, precision: 12, scale: 2, default: 0
  end
end
