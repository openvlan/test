class CreatePaymentMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_methods do |t|
      t.references :shipper, type: :uuid, foreign_key: true, null: false, index: {unique: true}

      t.string :payment_method, null: false
      t.string :payment_email, null: true

      t.timestamps
    end
  end
end
