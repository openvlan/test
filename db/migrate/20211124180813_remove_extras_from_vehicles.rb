class RemoveExtrasFromVehicles < ActiveRecord::Migration[5.2]
  def change
    remove_column :vehicles, :extras, :jsonb, default: {}
  end
end
