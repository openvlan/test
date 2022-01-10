class RemoveJobResults < ActiveRecord::Migration[5.2]
  def change
    drop_table :job_results
  end
end
