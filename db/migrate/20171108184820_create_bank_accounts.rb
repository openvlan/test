class CreateBankAccounts < ActiveRecord::Migration[5.1]
  def change
    remove_index :shippers, :bank_account
    remove_column :shippers, :bank_account, :jsonb, null: true, default: {}

    create_table :bank_accounts, id: :uuid do |t|
      t.string :bank_name
      t.string :number
      t.string :type
      t.string :cbu

      t.uuid :shipper_id, index: true

      t.timestamps
    end
    add_foreign_key :bank_accounts, :shippers

  end
end
