class AddMarketplaceRelatedStuff < ActiveRecord::Migration[5.1]
  def change
    remove_index :profiles, :preferences
    rename_column :profiles, :preferences, :extras
    add_index :profiles, :extras, using: :gin

    rename_column :users, :deleted_at, :discarded_at
    add_column :users, :institution_id, :uuid
    add_index :users, :institution_id
    add_index :users, :discarded_at
  end
end
