class ChangeLicenseNumberToString < ActiveRecord::Migration[5.2]
  def up
    change_column :licenses, :number, :string
  end

  def down
    change_column :licenses, :number, :integer, using: 'number::integer'
  end
end
