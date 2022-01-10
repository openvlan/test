class RemoveWebhookLogs < ActiveRecord::Migration[5.2]
  def change
    drop_table :webhook_logs
  end
end
