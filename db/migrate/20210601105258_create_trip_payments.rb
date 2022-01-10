class CreateTripPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_payments do |t|
      t.references :trip, type: :uuid, foreign_key: true, null: false, index: {unique: true}

      t.string :payment_method, null: false
      t.string :payment_email, null: false
      t.string :confirmation_code

      t.timestamps
    end
  end
end
