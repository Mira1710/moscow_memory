class CreatePlaces < ActiveRecord::Migration[8.1]
  def change
    create_table :places do |t|
      t.string :name
      t.text :description
      t.string :address
      t.decimal :latitude
      t.decimal :longitude
      t.integer :year_from
      t.integer :year_to

      t.timestamps
    end
  end
end
