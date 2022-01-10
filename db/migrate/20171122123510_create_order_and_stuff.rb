class CreateOrderAndStuff < ActiveRecord::Migration[5.1]
  def change
    create_table :institutions, id: :uuid do |t|
      t.string :name
      t.string :legal_name
      t.string :uid_type
      t.string :uid

      t.string :type

      t.timestamps
    end

    create_table :addresses, id: :uuid do |t|
      t.uuid :institution_id, index: true

      t.st_point :gps_coordinates, geographic: true

      t.string :street_1
      t.string :street_2
      t.string :zip_code
      t.string :city
      t.string :state
      t.string :country

      t.string :contact_name
      t.string :contact_cellphone
      t.string :contact_email

      t.string :telephone
      t.string :open_hours
      t.string :notes

      t.timestamps
    end
    add_index :addresses, :gps_coordinates, using: :gist
    add_foreign_key :addresses, :institutions

    create_table :orders, id: :uuid do |t|
      t.uuid :giver_id, index: true
      t.uuid :receiver_id, index: true
      t.date :expiration

      t.decimal :amount, precision: 12, scale:4, default: 0
      t.decimal :bonified_amount, precision: 12, scale:4, default: 0

      t.timestamps
    end

    create_table :deliveries do |t|
      t.uuid :order_id, index: true
      t.uuid :trip_id, index: true

      t.decimal :amount, precision: 12, scale:4, default: 0
      t.decimal :bonified_amount, precision: 12, scale:4, default: 0

      t.uuid :origin_id, index: true
      t.st_point :origin_gps_coordinates, geographic: true
      t.uuid :destination_id, index: true
      t.st_point :destination_gps_coordinates, geographic: true

      t.string :status

      t.timestamps
    end
    add_index :deliveries, :origin_gps_coordinates, using: :gist
    add_index :deliveries, :destination_gps_coordinates, using: :gist
    add_foreign_key :deliveries, :orders

    create_table :packages do |t|
      t.integer :delivery_id, index: true

      t.integer :weigth
      t.integer :volume

      t.boolean :cooling

      t.text :description

      t.uuid :attachment_id, index: true

      t.timestamps
    end
    add_foreign_key :packages, :deliveries

  end
end
