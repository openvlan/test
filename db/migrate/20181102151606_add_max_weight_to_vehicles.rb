class AddMaxWeightToVehicles < ActiveRecord::Migration[5.1]
  def change
    add_column :vehicles, :max_weight, :integer
  end
end
