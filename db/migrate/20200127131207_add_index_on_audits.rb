class AddIndexOnAudits < ActiveRecord::Migration[5.1]
  def change
    add_index :audits, [:audited_id, :audited_type]
  end
end
