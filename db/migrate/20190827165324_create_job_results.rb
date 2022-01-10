class CreateJobResults < ActiveRecord::Migration[5.1]
  def change
    create_table :job_results, id: :uuid do |t|
      t.string :name
      t.string :result
      t.string :message
      t.jsonb :extra_info

      t.timestamps
    end
  end
end
