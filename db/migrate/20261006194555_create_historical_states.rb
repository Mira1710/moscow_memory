class CreateHistoricalStates < ActiveRecord::Migration[8.1]
  def change
    create_table :historical_states do |t|
      t.references :place, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :year_from
      t.integer :year_to
      t.string :image

      t.timestamps
    end
  end
end
