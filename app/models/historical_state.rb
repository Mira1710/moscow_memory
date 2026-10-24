class HistoricalState < ApplicationRecord
  include ArticleGalleries
  belongs_to :place, inverse_of: :historical_states
  article_gallery :images
  article_gallery :preserved_images
  article_gallery :lost_images

  validates :title, presence: true
  validates :year_from, :year_to, numericality: { only_integer: true }, allow_blank: true
  validate :chronological_years

  def chronological_years
    errors.add(:year_to, "не может быть раньше начала периода") if year_from && year_to && year_to < year_from
  end
end
