class RemoveUntrackedActivity < ActiveRecord::Migration[5.2]
  def change
    drop_table :untracked_activities
  end
end
