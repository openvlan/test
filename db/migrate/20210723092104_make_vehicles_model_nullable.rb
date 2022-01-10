class MakeVehiclesModelNullable < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:vehicles, :model, true)
  end
end
