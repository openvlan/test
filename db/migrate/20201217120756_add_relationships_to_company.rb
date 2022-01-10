class AddRelationshipsToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :shippers, :status, :string, default: "0"
    add_column :shippers, :company_id, :integer
    add_index  :shippers, :company_id      
    
    add_column :addresses, :formatted_address, :string
    add_column :addresses, :company_id, :integer
    add_index  :addresses, :company_id  
    
    remove_column :bank_accounts, :shipper_id, :uuid
    add_column :bank_accounts, :routing_number, :integer
    add_column :bank_accounts, :company_id, :integer
    add_index  :bank_accounts, :company_id  

    add_column :shippers, :working_hours, :jsonb, default: {}
    add_column :shippers, :first_name, :string
    
    add_column :vehicles, :truck_type, :integer
    add_column :vehicles, :make, :string
    add_column :vehicles, :color, :string
    add_column :vehicles, :license_plate, :string
    add_column :vehicles, :insurance_provider, :string
    add_column :vehicles, :has_liftgate, :boolean
    add_column :vehicles, :has_forklift, :boolean
    add_column :vehicles, :gross_vehicle_weight_rating, :decimal
  end
end
