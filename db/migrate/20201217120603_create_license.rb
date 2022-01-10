class CreateLicense < ActiveRecord::Migration[5.1]
  def change
    create_table :licenses do |t|
      t.integer :number
      t.string :state
      t.datetime :expiration_date

      t.timestamps
    end

    add_column :licenses, :shipper_id, :uuid
    add_index  :licenses, :shipper_id   
  end
end
