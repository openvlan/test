class ChangeGrossVehicleWeightRatingColumnType < ActiveRecord::Migration[5.2]
  def up
    change_column :vehicles, :gross_vehicle_weight_rating, :integer
  end

  def down
    change_column :vehicles, :gross_vehicle_weight_rating, :decimal
  end
end
