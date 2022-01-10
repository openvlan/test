class RemovePackages < ActiveRecord::Migration[5.2]
  def change
    drop_table :packages
  end
end
