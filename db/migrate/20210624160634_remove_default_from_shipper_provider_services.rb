class RemoveDefaultFromShipperProviderServices < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:shippers, :provided_services, nil)
  end
end
