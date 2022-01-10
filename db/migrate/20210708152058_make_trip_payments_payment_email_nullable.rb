class MakeTripPaymentsPaymentEmailNullable < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:trip_payments, :payment_email, true)
  end
end
