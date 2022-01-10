class AddMilestones < ActiveRecord::Migration[5.1]
  def change
    create_table :milestones do |t|
      t.uuid  :trip_id
      t.string  :name
      t.text   :comments

      t.jsonb   :data, null: true, default: {}

      t.st_point :gps_coordinates, geographic: true

      t.datetime :created_at
    end
    add_index :milestones, :trip_id
    add_index :milestones, :data, using: :gin
    add_index :milestones, :gps_coordinates, using: :gist
  end
end
