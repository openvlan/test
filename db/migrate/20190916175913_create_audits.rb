class CreateAudits < ActiveRecord::Migration[5.1]
  def change
    create_table :audits, id: :uuid do |t|
      t.string :audited_id
      t.string :audited_type
      t.string :message
      t.string :field
      t.string :original_value
      t.string :new_value
      t.uuid :user_id

      t.timestamps
    end
  end
end
