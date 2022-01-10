class CreateAccountBalances < ActiveRecord::Migration[5.1]
  def change
    create_table :account_balances, id: :uuid do |t|
      t.uuid :institution_id
      t.decimal :amount, precision: 12, scale: 4, default: 0

      t.timestamps
    end

    add_index  :account_balances, :institution_id, unique: true
  end
end
