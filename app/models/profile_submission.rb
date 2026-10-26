class ProfileSubmission < ApplicationRecord
  belongs_to :user
  mount_uploader :image, ArticleImageUploader
  KINDS = { "route" => "Маршрут", "photo" => "Фото", "map" => "Карта", "sound" => "Звук" }.freeze
  STATUSES = { "pending" => "На модерации", "accepted" => "Приняты", "revision" => "Нужно уточнить" }.freeze
  validates :kind, inclusion: { in: KINDS.keys }
  validates :status, inclusion: { in: STATUSES.keys }
  validates :title, presence: true, length: { maximum: 150 }
  validates :description, length: { maximum: 10000 }
  validate :image_size

  private

  def image_size
    errors.add(:image, "не больше 10 МБ") if image.present? && image.size > 10.megabytes
  end
end
