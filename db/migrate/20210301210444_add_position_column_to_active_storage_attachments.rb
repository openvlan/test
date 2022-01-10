class AddPositionColumnToActiveStorageAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :active_storage_attachments, :position, :integer, default: 0
  end
end
