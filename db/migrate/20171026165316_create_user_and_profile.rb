class CreateUserAndProfile < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :username, index: true, unique: true
      t.string :email, index: true, unique: true
      t.string :password_digest

      t.integer :token_expire_at

      t.integer  :login_count, default: 0, null: false
      t.integer  :failed_login_count, default: 0, null: false
      t.datetime :last_login_at
      t.string   :last_login_ip

      # To check states
      t.boolean :active, default: false
      t.boolean :confirmed, default: false

      t.integer :roles_mask, index: true

      t.jsonb :settings, null: false, default: {}

      t.datetime :deleted_at

      t.timestamps
    end

    create_table :profiles, id: :uuid do |t|
      t.string :first_name
      t.string :last_name

      t.uuid :user_id, null: false, index: true

      t.jsonb :preferences, null: false, default: {}

      t.timestamps
    end

    add_index  :users, :settings, using: :gin
    add_index  :profiles, :preferences, using: :gin
  end
end


