class AddPeriodSectionsAndAdminUsers < ActiveRecord::Migration[8.1]
  def change
    change_table :historical_states do |t|
      t.boolean :show_preserved, default: false, null: false
      t.boolean :show_lost, default: false, null: false
      t.text :preserved_text
      t.text :lost_text
      t.jsonb :preserved_images, default: [], null: false
      t.jsonb :lost_images, default: [], null: false
    end
    create_table :admin_users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamps
    end
    add_index :admin_users, :email, unique: true
    add_index :admin_users, "(true)", unique: true, name: "index_admin_users_single_owner"
  end
end
