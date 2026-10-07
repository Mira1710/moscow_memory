class AddImageToPlaces < ActiveRecord::Migration[8.1]
  def change
    add_column :places, :image, :string
  end
end
