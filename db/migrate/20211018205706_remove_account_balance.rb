class RemoveAccountBalance < ActiveRecord::Migration[5.2]
  def change
    drop_table :account_balances
  end
end
