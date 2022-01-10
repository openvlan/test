class AddPaidAtToTripPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :trip_payments, :paid_at, :datetime
  end
end
