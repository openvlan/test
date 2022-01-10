class FixWeightOnPackages < ActiveRecord::Migration[5.1]
  def change
    rename_column :packages, :weigth, :weight
  end
end
