class SavedRoute < ApplicationRecord
  belongs_to :user
  validates :route_key, presence: true, uniqueness: { scope: :user_id }
  validate :known_route

  def self.catalogue
    YAML.safe_load_file(Rails.root.join("config/walking_routes.yml")).fetch("sections").flat_map { |section| section.fetch("cards") }.index_by { |card| card.fetch("image") }
  end

  def card
    self.class.catalogue[route_key]
  end

  private

  def known_route
    errors.add(:route_key, "маршрут не найден") unless card
  end
end
