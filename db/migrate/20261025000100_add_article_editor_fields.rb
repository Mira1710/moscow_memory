class AddArticleEditorFields < ActiveRecord::Migration[8.1]
  def change
    change_table :places do |t|
      t.string :category
      t.string :founded
      t.string :architectural_style
      t.string :architect
      t.text :sources
      t.jsonb :photo_images, default: [], null: false
      t.jsonb :map_images, default: [], null: false
      t.jsonb :object_images, default: [], null: false
    end
    add_column :historical_states, :images, :jsonb, default: [], null: false
  end
end
