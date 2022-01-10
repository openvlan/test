class CreateShippers < ActiveRecord::Migration[5.1]
  def change
    create_table :shippers, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :gender
      t.date :birth_date
      t.string :email, null: false
      t.string :phone_num
      t.string :photo
      t.boolean :active, null: true, default: false
      t.boolean :verified, null: true, default: false
      t.date :verified_at

      t.jsonb :national_ids, null: true, default: {}

      t.jsonb :bank_account, null: true, default: {}

      t.jsonb :vehicles, null: true, default: {}

      t.string :gateway
      t.string :gateway_id, null: false
      t.jsonb :data, null: true, default: {}

      t.jsonb :minimum_requirements, null: true, default: {}
      t.jsonb :requirements, null: true, default: {}

      t.timestamps
    end

    add_index  :shippers, :national_ids, using: :gin
    add_index  :shippers, :bank_account, using: :gin
    add_index  :shippers, :vehicles, using: :gin
    add_index  :shippers, :data, using: :gin
    add_index  :shippers, :minimum_requirements, using: :gin
    add_index  :shippers, :requirements, using: :gin
  end
end
