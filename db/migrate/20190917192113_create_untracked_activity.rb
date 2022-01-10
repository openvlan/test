class CreateUntrackedActivity < ActiveRecord::Migration[5.1]
  def change
    create_table :untracked_activities, id: :uuid do |t|
      t.uuid :institution_id
      t.uuid :author_id
      t.string :reason
      t.string :activity
      t.decimal :amount, precision: 12, scale:4, default: 0
      t.timestamps
      t.string :network_id
    end
  end
end
