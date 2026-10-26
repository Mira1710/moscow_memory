class CreateUserProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :username, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :session_version, null: false, default: 0
      t.jsonb :notification_preferences, null: false, default: {}
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    create_table :profile_submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :title, null: false
      t.text :description
      t.string :image
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
    create_table :saved_places do |t|
      t.references :user, null: false, foreign_key: true
      t.references :place, null: false, foreign_key: true
      t.timestamps
    end
    add_index :saved_places, [ :user_id, :place_id ], unique: true
  end
end
