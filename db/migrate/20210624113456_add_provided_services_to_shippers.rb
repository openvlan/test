class AddProvidedServicesToShippers < ActiveRecord::Migration[5.1]
  def change
    add_column :shippers, :provided_services, :string, default: ['ltl'], array: true
  end
end
