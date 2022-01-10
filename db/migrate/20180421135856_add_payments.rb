class AddPayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.string  :status
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :collected_amount, precision: 10, scale: 2

      t.string  :payable_type
      t.string  :payable_id

      t.string  :gateway
      t.string  :gateway_id
      t.jsonb   :gateway_data, null: true, default: {}

      t.jsonb   :notifications

      t.timestamps
    end
    add_index :payments, :gateway_data, using: :gin
    add_index :payments, :notifications, using: :gin
    add_index :payments, %i(payable_type payable_id)
    add_index :payments, %i(gateway gateway_id)

    create_table :webhook_logs do |t|
      t.string  :service

      t.string  :path, limit: 1024

      t.jsonb   :parsed_body, null: true, default: {}

      t.string  :ip
      t.string  :user_agent

      t.datetime :requested_at
    end
    add_index :webhook_logs, :parsed_body, using: :gin
  end
end
