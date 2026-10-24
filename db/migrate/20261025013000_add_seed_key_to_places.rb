class AddSeedKeyToPlaces < ActiveRecord::Migration[8.1]
  def change
    add_column :places, :seed_key, :string
    add_index :places, :seed_key, unique: true
  end
end
