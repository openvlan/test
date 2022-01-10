class AddTermsAcceptanceToShipper < ActiveRecord::Migration[5.1]
  def change
    add_column :shippers, :has_accepted_tdu, :boolean, default: false
  end
end
