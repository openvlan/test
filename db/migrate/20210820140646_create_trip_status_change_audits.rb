class CreateTripStatusChangeAudits < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_status_change_audits do |t|
      t.belongs_to :trip, foreign_key: true, type: :uuid
      t.string :status
      t.string :event
      t.text :comments

      t.timestamps
    end
  end
end
