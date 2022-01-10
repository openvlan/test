class AddIndexOnTripStatus < ActiveRecord::Migration[5.1]
  def change
    add_index :trips, :status
  end
end
