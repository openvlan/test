class ConvertOrderWeightToLb < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :weight, :decimal, :precision => 18, :scale => 6, default: nil
    Order.update_all('weight = weight * 2.20462262185')
    rename_column :orders, :weight, :total_weight_in_lb
  end
end
