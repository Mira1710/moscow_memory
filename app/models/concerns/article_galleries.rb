module ArticleGalleries
  extend ActiveSupport::Concern

  class_methods do
    def article_gallery(column)
      mount_uploaders column, ArticleImageUploader
      before_save { self[column] = [] if self[column].nil? }
      define_method("new_#{column}=") do |files|
        additions = Array(files).reject(&:blank?)
        public_send("#{column}=", public_send(column) + additions) if additions.any?
      end
      define_method("remove_#{column}=") do |identifiers|
        removed = Array(identifiers).reject(&:blank?)
        public_send("#{column}=", public_send(column).reject { |image| removed.include?(image.identifier) }) if removed.any?
      end
    end
  end
end
