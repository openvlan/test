class AddCommentToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :comment, :string, default: ''
  end
end
