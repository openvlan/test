class DropBankAccounts < ActiveRecord::Migration[5.2]
  def change
    drop_table :bank_accounts
  end
end
