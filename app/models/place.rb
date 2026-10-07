class Place < ApplicationRecord
  mount_uploader :image, PlaceImageUploader

  has_many :historical_states, dependent: :destroy
end