class CreateLaunchSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :launch_subscriptions do |t|
      t.string :email, null: false
      t.datetime :consent_accepted_at, null: false
      t.string :source, null: false
      t.timestamps
    end
    add_index :launch_subscriptions, :email, unique: true
  end
end
