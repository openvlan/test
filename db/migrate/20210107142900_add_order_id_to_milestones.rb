class AddOrderIdToMilestones < ActiveRecord::Migration[5.2]
  def change
    add_column :milestones, :marketplace_order_id, :string
    add_index  :milestones, :marketplace_order_id      
  end
end
