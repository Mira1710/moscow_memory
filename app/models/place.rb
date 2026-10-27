class Place < ApplicationRecord
  include ArticleGalleries

  ARTICLE_TOPICS = {
    "zamoskvorechye" => "Замоскворечье", "sokolniki" => "Сокольники", "basmanny" => "Басманный район",
    "sukharev_tower" => "Сухарева башня", "mokrinsky_lane" => "Мокринский переулок", "red_gate" => "Красные ворота",
    "sounds" => "Звуки", "photography" => "Москва в объективе", "maps" => "Старые карты"
  }.freeze

  CATEGORIES = {
    "public_spaces" => "Городские пространства",
    "houses" => "Жилые дома",
    "public_buildings" => "Общественные здания",
    "churches" => "Церковная архитектура",
    "estates" => "Усадьбы",
    "industrial" => "Промышленные объекты",
    "metro" => "Метро",
    "lost" => "Исчезнувшее"
  }.freeze

  mount_uploader :image, ArticleImageUploader
  article_gallery :photo_images
  article_gallery :map_images
  article_gallery :object_images

  has_many :saved_places, dependent: :destroy
  has_many :historical_states, dependent: :destroy, inverse_of: :place
  accepts_nested_attributes_for :historical_states, allow_destroy: true, reject_if: :blank_history?

  def blank_history?(attributes)
    return false if attributes["id"].present?
    text = %w[title description year_from year_to preserved_text lost_text images_cache preserved_images_cache lost_images_cache]
    uploads = %w[new_images new_preserved_images new_lost_images]
    enabled = %w[show_preserved show_lost].any? { |key| ActiveModel::Type::Boolean.new.cast(attributes[key]) }
    !enabled && text.all? { |key| attributes[key].blank? } && uploads.all? { |key| Array(attributes[key]).reject(&:blank?).empty? }
  end

  validates :name, presence: true
  validates :article_topic, inclusion: { in: ARTICLE_TOPICS.keys }, allow_blank: true
  validates :category, inclusion: { in: CATEGORIES.keys }, allow_blank: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_blank: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_blank: true
  validates :year_from, :year_to, numericality: { only_integer: true }, allow_blank: true
  validate :chronological_years

  def chronological_years
    errors.add(:year_to, "не может быть раньше начала периода") if year_from && year_to && year_to < year_from
  end
end
