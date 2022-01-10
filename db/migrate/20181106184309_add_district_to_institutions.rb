class AddDistrictToInstitutions < ActiveRecord::Migration[5.1]
  def change
    add_column :institutions, :district_id, :uuid
    add_index :institutions, :district_id

    add_foreign_key :institutions, :districts
  end
end
