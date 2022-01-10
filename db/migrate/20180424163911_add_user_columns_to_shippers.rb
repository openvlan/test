class AddUserColumnsToShippers < ActiveRecord::Migration[5.1]
  def up
    change_table :shippers do |t|
      t.string :password_digest

      t.integer :token_expire_at

      t.integer  :login_count, default: 0, null: false
      t.integer  :failed_login_count, default: 0, null: false
      t.datetime :last_login_at
      t.string   :last_login_ip
    end

    Shipper.find_each do |shipper|
      shipper.password = "#{shipper.first_name.downcase}!#{shipper.gateway_id}"
      shipper.save!
    end
  end

  def down
    remove_column :shippers, :password_digest
    remove_column :shippers, :token_expire_at
    remove_column :shippers, :login_count
    remove_column :shippers, :failed_login_count
    remove_column :shippers, :last_login_at
    remove_column :shippers, :last_login_ip
  end
end
