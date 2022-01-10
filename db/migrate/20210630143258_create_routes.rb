class CreateRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :routes do |t|
      t.string :role
      t.string :path, null: false

      t.index ['role','path'], name: 'unique_path_per_route', unique: true
    end
  end
end
