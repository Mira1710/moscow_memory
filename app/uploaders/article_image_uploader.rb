class ArticleImageUploader < PlaceImageUploader
  def extension_allowlist
    %w[jpg jpeg png webp gif]
  end

  def content_type_allowlist
    %r{\Aimage/(jpeg|png|webp|gif)\z}
  end
end
