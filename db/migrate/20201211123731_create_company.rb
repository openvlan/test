class CreateCompany < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.integer :ein
      t.decimal :max_distance_from_base
      t.integer :usdot
      t.integer :mc_number_type, default: 0
      t.integer :mc_number
      t.string :sacs_number

      t.timestamps
    end
  end
end
