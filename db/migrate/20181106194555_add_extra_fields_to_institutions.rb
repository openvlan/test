class AddExtraFieldsToInstitutions < ActiveRecord::Migration[5.1]
  def change
    add_column :institutions, :beneficiaries, :integer
    add_column :institutions, :offered_services, :string, array: true, default: []
  end
end
