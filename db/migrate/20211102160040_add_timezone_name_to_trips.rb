class AddTimezoneNameToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :timezone_name, :string, null: false, default: 'America/New_York'
    change_column_default :trips, :timezone_name, nil
  end
end
