class RemoveOldPhoneNumberFromShipper < ActiveRecord::Migration[5.2]
  def change
    remove_column :shippers, :old_phone_num
  end
end
