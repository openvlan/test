class RemoveUserColumnsToShippers < ActiveRecord::Migration[5.1]
  def change
    remove_column :shippers, :password_digest, :string
    remove_column :shippers, :token_expire_at, :integer
    remove_column :shippers, :login_count, :integer
    remove_column :shippers, :failed_login_count, :integer
    remove_column :shippers, :last_login_at, :datetime
    remove_column :shippers, :last_login_ip, :string
    remove_column :shippers, :first_name, :string
    remove_column :shippers, :email, :string

    add_column :shippers, :user_id, :uuid, null: false

    reversible do |dir|
      dir.up do
        change_column :shippers, :gateway_id, :string, :null => true
      end
      dir.down do
        change_column :shippers, :gateway_id, :string, :null => false
      end
    end
  end
end
