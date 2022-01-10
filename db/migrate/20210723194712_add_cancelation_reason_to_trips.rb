class AddCancelationReasonToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :cancelation_reason, :text
  end
end
