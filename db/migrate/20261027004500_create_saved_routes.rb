class CreateSavedRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :saved_routes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :route_key, null: false
      t.timestamps
    end
    add_index :saved_routes, [ :user_id, :route_key ], unique: true
  end
end
