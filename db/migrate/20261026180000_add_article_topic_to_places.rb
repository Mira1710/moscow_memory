class AddArticleTopicToPlaces < ActiveRecord::Migration[8.1]
  def change
    add_column :places, :article_topic, :string
    add_index :places, :article_topic
  end
end
