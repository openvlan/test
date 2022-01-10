class CreateTripOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_orders do |t|
      t.references :trip, type: :uuid, index: true, foreign_key: true
      t.references :order, type: :uuid, index: true, foreign_key: true

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
