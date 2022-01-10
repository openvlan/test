class UnifyShipperPhoneNumberWithUserPhoneNumber < ActiveRecord::Migration[5.2]
  def up
    add_column :shippers, :old_phone_num, :string

    Shipper.all.each { |s| s.old_phone_num = s[:phone_num]; s.save(validate: false) }

    remove_column :shippers, :phone_num
  end

  def down
    add_column :shippers, :phone_num, :string

    Shipper.all.each { |s| s[:phone_num] = s.old_phone_num; s.save(validate: false) }

    remove_column :shippers, :old_phone_num
  end
end
